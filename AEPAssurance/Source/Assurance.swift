/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import AEPServices
import Foundation

public class Assurance: NSObject, Extension {

    public var name = AssuranceConstants.EXTENSION_NAME
    public var friendlyName = AssuranceConstants.FRIENDLY_NAME
    public static var extensionVersion = AssuranceConstants.EXTENSION_VERSION
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime

    let datastore = NamedCollectionDataStore(name: AssuranceConstants.EXTENSION_NAME)
    var assuranceSession: AssuranceSession?
    var shouldProcessEvents: Bool = true
    var timer: DispatchSourceTimer?

    var sessionId: String? {
        get {
            datastore.getString(key: AssuranceConstants.DataStoreKeys.SESSION_ID)
        }
        set {
            datastore.set(key: AssuranceConstants.DataStoreKeys.SESSION_ID, value: newValue)
        }
    }

    private let DEFAULT_ENVIRONMENT = AssuranceEnvironment.prod
    var environment: AssuranceEnvironment {
        get {
            AssuranceEnvironment.init(envString: datastore.getString(key: AssuranceConstants.DataStoreKeys.ENVIRONMENT) ?? DEFAULT_ENVIRONMENT.rawValue)
        }
        set {
            datastore.set(key: AssuranceConstants.DataStoreKeys.ENVIRONMENT, value: newValue.rawValue)
        }
    }
    
    var connectedSocketURL: String? {
        get {
            datastore.getString(key: AssuranceConstants.DataStoreKeys.SOCKETURL)
        }
        set {
            if let newValue = newValue {
                datastore.set(key: AssuranceConstants.DataStoreKeys.SOCKETURL, value: newValue)
            } else {
                datastore.remove(key: AssuranceConstants.DataStoreKeys.SOCKETURL)
            }
        }
    }

    // getter for client ID
    lazy var clientID: String = {
        // return with clientId, if it is already available in persistence
        if let persistedClientID = datastore.getString(key: AssuranceConstants.DataStoreKeys.CLIENT_ID) {
            return persistedClientID
        }

        // If not generate a new clientId
        let newClientID = UUID().uuidString
        datastore.set(key: AssuranceConstants.DataStoreKeys.CLIENT_ID, value: newClientID)
        return newClientID

    }()

    public func onRegistered() {
        registerListener(type: EventType.wildcard, source: EventSource.wildcard, listener: handleWildcardEvent)
        self.assuranceSession = AssuranceSession(self)
        
        /// if the Assurance session was already connected in the previous app session, go ahead and reconnect socket
        /// and do not turn on the unregister timer
        if let _ = self.connectedSocketURL {
            shareState()
            assuranceSession?.startSession()
            return
        }
        
        /// if the Assurance session is not previously connected, turn on 5 sec timer to wait for Assurance deeplink
        startShutDownTimer()
    }

    public func onUnregistered() {}

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
    }

    public func readyForEvent(_ event: Event) -> Bool {
        return true
    }

    private func handleAssuranceRequestContent(event: Event) {
        guard let startSessionData = event.data else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with empty data. Dropping event.")
            return
        }

        guard let deeplinkUrlString = startSessionData[AssuranceConstants.EventDataKey.START_SESSION_URL] as? String else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with no deeplink url. Dropping event.")
            return
        }

        let deeplinkURL = URL(string: deeplinkUrlString)
        guard let sessionId = deeplinkURL?.params[AssuranceConstants.Deeplink.SESSIONID_KEY] else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Deeplink URL is invalid. Does not contain 'adb_validation_sessionid' query parameter : " + deeplinkUrlString)
            return
        }

        // make sure the sessionID is an UUID string
        guard let _ = UUID(uuidString: sessionId) else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Deeplink URL is invalid. It contains sessionId that is not an valid UUID : " + deeplinkUrlString)
            return
        }

        // Read the environment query parameter from the deeplink url
        let environmentString = deeplinkURL?.params[AssuranceConstants.Deeplink.ENVIRONMENT_KEY] ?? ""
        
        // invalidate the timer
        invalidateTimer()

        shouldProcessEvents = true
        
        // save the environment and sessionID
        environment = AssuranceEnvironment.init(envString: environmentString)
        self.sessionId = sessionId
        shareState()
        assuranceSession?.startSession()
    }

    /// Called by the wildcard listener to handle all the events dispatched from MobileCore's event hub.
    /// Each mobile core event is converted to `AssuranceEvent` and is sent over the socket.
    /// - Parameters:
    /// - event - a mobileCore's `Event`
    private func handleWildcardEvent(event: Event) {
        if event.isAssuranceRequestContent {
            handleAssuranceRequestContent(event: event)
        }
        
        if !shouldProcessEvents {
            return
        }
            
        if event.isSharedStateEvent {
            processSharedStateEvent(event: event)
            return
        }

        let assuranceEvent = AssuranceEvent.from(mobileCoreEvent: event)
        assuranceSession?.sendEvent(assuranceEvent)
        
        
        if event.isPlacesRequestEvent {
            handlePlacesRequest(event: event)
        } else if event.isPlacesResponseEvent {
            handlePlacesResponse(event: event)
        }
    }

    /// Method to process the sharedState events from the event hub.
    /// Shared State Change events are special events to Assurance.  On the arrival of which, Assurance extension attempts to
    /// extract the shared state details associated with the shared state change, and then append them to this event.
    /// Assurance extension handles both regular and XDM shared state change events.
    ///
    /// - Parameters:
    ///     - event - a mobileCore's `Event`
    private func processSharedStateEvent(event: Event) {
        // early bail out if unable to find the stateOwner
        guard let stateOwner = event.sharedStateOwner else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to find shared state owner for the shared state change event. Dropping event.")
            return
        }

        // Differentiate the type of shared state using the event name and get the state content accordingly
        // Event Name for XDM shared          = "Shared state content (XDM)"
        // Event Name for Regular  shared     = "Shared state content"
        var sharedStateResult: SharedStateResult?
        var sharedContentKey: String

        if AssuranceConstants.SDKEventName.XDM_SHARED_STATE_CHANGE.lowercased() == event.name.lowercased() {
            sharedContentKey = AssuranceConstants.PayloadKey.XDM_SHARED_STATE_DATA
            sharedStateResult = runtime.getXDMSharedState(extensionName: stateOwner, event: nil, barrier: false)
        } else {
            sharedContentKey = AssuranceConstants.PayloadKey.SHARED_STATE_DATA
            sharedStateResult = runtime.getSharedState(extensionName: stateOwner, event: nil, barrier: false)
        }

        // do not send any sharedState thats empty, this includes Assurance not logging any pending shared states
        guard let sharedState = sharedStateResult else {
            return
        }

        if sharedState.status != .set {
            return
        }

        let sharedStatePayload = [sharedContentKey: sharedState.value]
        var assuranceEvent = AssuranceEvent.from(mobileCoreEvent: event)
        assuranceEvent.payload?.updateValue(AnyCodable.init(sharedStatePayload), forKey: AssuranceConstants.PayloadKey.METADATA)
        assuranceSession?.sendEvent(assuranceEvent)
    }

    func getAllExtensionStateData() -> [AssuranceEvent] {
        var stateEvents: [AssuranceEvent] = []
        
        let eventHubState = runtime.getSharedState(extensionName: AssuranceConstants.SharedStateName.EVENT_HUB, event: nil, barrier: false)
        guard eventHubState?.status == .set, let registeredExtension = eventHubState?.value else {
            return stateEvents
        }
        
        guard let extensionsMap = registeredExtension[AssuranceConstants.EventDataKey.EXTENSIONS] as? [String:Any] else {
            return stateEvents
        }
            

        for (extensionName, _) in extensionsMap {
            let friendlyName = getFriendlyExtensionName(extensionMap: extensionsMap, extensionName: extensionName)
            stateEvents.append(contentsOf: getStateForExtension(stateOwner: extensionName, eventName: "\(friendlyName) State"))
        }

        return stateEvents
    }

    
    // MARK:- Private methods
    
    private func getFriendlyExtensionName(extensionMap: [String: Any], extensionName: String) -> String {
        if let extensionDetails = extensionMap[extensionName] as? [String: Any] {
            if let friendlyName = extensionDetails[AssuranceConstants.EventDataKey.FRIENDLY_NAME] as? String {
                return friendlyName
            }
        }
        return extensionName
    }
    
    private func getStateForExtension(stateOwner: String, eventName: String) -> Array<AssuranceEvent> {
        var stateEvents: [AssuranceEvent] = []
        
        let regularSharedState = runtime.getSharedState(extensionName: stateOwner, event: nil, barrier: false)
        if regularSharedState?.status == .set, let stateValue = regularSharedState?.value {
            stateEvents.append(prepareShareStateEvent(owner: stateOwner, eventName: eventName, stateContent: stateValue, stateType: AssuranceConstants.PayloadKey.SHARED_STATE_DATA))
        }
        
        let xdmSharedState = runtime.getXDMSharedState(extensionName: stateOwner, event: nil, barrier: false)
        if xdmSharedState?.status == .set, let xdmStateValue = xdmSharedState?.value {
            stateEvents.append(prepareShareStateEvent(owner: stateOwner, eventName: eventName, stateContent: xdmStateValue, stateType: AssuranceConstants.PayloadKey.XDM_SHARED_STATE_DATA))
        }
        
        return stateEvents
    }
    
    private func prepareShareStateEvent(owner : String, eventName: String, stateContent: [String:Any], stateType: String) -> AssuranceEvent {
        var payload: [String: AnyCodable] = [:]
        payload[AssuranceConstants.ACPExtensionEventKey.NAME] = AnyCodable.init(eventName)
        payload[AssuranceConstants.ACPExtensionEventKey.TYPE] = AnyCodable.init(EventType.hub.lowercased)
        payload[AssuranceConstants.ACPExtensionEventKey.SOURCE] = AnyCodable.init(EventSource.sharedState.lowercased)
        payload[AssuranceConstants.ACPExtensionEventKey.DATA] = [AssuranceConstants.EventDataKey.SHARED_STATE_OWNER: owner]
        payload[AssuranceConstants.PayloadKey.METADATA] = [stateType:stateContent]
        return AssuranceEvent(type: AssuranceConstants.EventType.GENERIC, payload: payload)
    }
    
    private func startShutDownTimer() {
        let queue = DispatchQueue.init(label: "com.adobe.assurance.shutdowntimer", qos: .background)
        timer = createDispatchTimer(queue: queue, block: {
            self.shutDownAssurance()
        })
    }

    private func shutDownAssurance() {
        shouldProcessEvents = false
        Log.debug(label: AssuranceConstants.LOG_TAG, "Timeout - Assurance did not receive deeplink to start Assurance session. Shutting down Assurance extension")
        invalidateTimer()
        self.assuranceSession?.clearQueueEvents()
        Log.debug(label: AssuranceConstants.LOG_TAG, "Clearing the queued events and purging Assurance shared state")
        clearState()
    }

    private func invalidateTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func createDispatchTimer(queue: DispatchQueue, block : @escaping () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(wallDeadline: .now() + 5)
        timer.setEventHandler(handler: block)
        timer.resume()
        return timer
    }
    
    // MARK: Places event handlers
    private func handlePlacesRequest(event : Event) {
        if event.isRequestNearByPOIEvent {
            assuranceSession?.addClientLog("Places - Requesting \(event.poiCount) nearby POIs from (\(event.latitude), \(event.longitude))", visibility: .normal)
        }
        else if event.isRequestResetEvent{
            assuranceSession?.addClientLog("Places - Resetting location", visibility: .normal)
        }
    }
    
    private func handlePlacesResponse(event : Event) {
        if event.isResponseRegionEvent {
            assuranceSession?.addClientLog("Places - Processed \(event.regionEventType) for region \(event.regionName).", visibility: .normal)
        }
        else if event.isResponseNearByEvent {
            let nearByPOIs = event.nearByPOIs
            for poi in nearByPOIs {
                guard let poiDictionary = poi as? Dictionary<String,Any> else {
                    return
                }
                assuranceSession?.addClientLog("\t  \(poiDictionary["regionname"] as? String ?? "Unknown")", visibility: .high)
            }
            assuranceSession?.addClientLog("Places - Found \(nearByPOIs.count) nearby POIs \(nearByPOIs.count>0 ? ":" : ".")", visibility: .high)
        }
    }
}
