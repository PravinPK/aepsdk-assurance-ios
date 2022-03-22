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
import AEPServices
import Foundation

class AssuranceSessionOrchestrator: AssurancePresentationDelegate {

    var outboundQueue: ThreadSafeQueue<AssuranceEvent>?
    let stateManager: AssuranceStateManager
    var session: AssuranceSession?

    /// true indicates Assurance SDK has timeout and shutdown after non-reception of deep link URL because of which it has cleared all the queued initial SDK events from memory.
    //var didShutDown: Bool = false

    init(stateManager: AssuranceStateManager) {
        outboundQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
        self.stateManager = stateManager
    }

    func createSession() {
        if session != nil {
            Log.debug(label: AssuranceConstants.LOG_TAG, "There is already an ongoing Assurance session. Ignoring to start new session.")
            return
        }
        
        //didShutDown = false

        session = AssuranceSession(stateManager, self, outboundEventQueue: outboundQueue ?? <#default value#>)
        outboundQueue = nil
        session?.startSession()
    }

    func sendEvent(_ assuranceEvent: AssuranceEvent) {
        guard let session = session else {
            session?.sendEvent(assuranceEvent)
            return
        }
        
        guard let outboundQueue = outboundQueue else {
            outboundQueue.enqueue(newElement: assuranceEvent)
            processQueuedOutBoundEvents()
            return
        }
        
        // not alive
    }

    private func processQueuedOutBoundEvents() {
        guard let unwrappedSession = session else {
            return
        }

        while self.outboundQueue.size() > 0 {
            let event = self.outboundQueue.dequeue()
            if let event = event {
                unwrappedSession.sendEvent(event)
            }
        }
    }
    
    func canProcessSDKEvents() {
        
    }

    ///
    /// Terminates the ongoing Assurance session.
    ///
    func terminateSession() {
        clearActiveSession()
    }

    func shutDownAssurance() {
        clearActiveSession()
    }

    func getActiveSession() -> AssuranceSession? {
        return session
    }

    func onPinConfirmation(_ url: URL) {
        session?.socket.connect(withUrl: url)
    }

    func onDisconnect() {
        clearActiveSession()
    }
    
    private func clearActiveSession() {
        session?.terminateSession()
        session = nil
        outboundQueue = nil
    }

}
