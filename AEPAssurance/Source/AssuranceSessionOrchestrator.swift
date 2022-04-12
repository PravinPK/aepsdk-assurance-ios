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

    /// A queue to hold the captured AssuranceEvent's before a session is connected.
    /// A nil value on this queue indicates that the AssuranceExtension is shut down or terminated
    var eventQueue: ThreadSafeQueue<AssuranceEvent>?
    let stateManager: AssuranceStateManager
    var session: AssuranceSession?
    init(stateManager: AssuranceStateManager) {
        eventQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
        self.stateManager = stateManager
    }

    func createSession() {
        if session != nil {
            Log.debug(label: AssuranceConstants.LOG_TAG, "There is already an ongoing Assurance session. Ignoring to start new session.")
            return
        }

        session = AssuranceSession(stateManager, self, eventQueue)
        eventQueue = nil
        session?.startSession()
    }

    func sendEvent(_ assuranceEvent: AssuranceEvent) {
        
        /// If there is an ongoing session, queue the event directly to that session
        if let session = session {
            session.sendEvent(assuranceEvent)
            return
        }

        guard let eventQueue = eventQueue else {
            return
        }
        eventQueue.enqueue(newElement: assuranceEvent)
    }

//    private func processQueuedOutBoundEvents() {
//        guard let unwrappedSession = session else {
//            return
//        }
//
//        while self.eventQueue.size() > 0 {
//            let event = self.eventQueue.dequeue()
//            if let event = event {
//                    unwrappedSession.sendEvent(event)
//                }
//            }
//    }

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

    // MARK: - AssurancePresentationDelegate methods
    func onPinConfirmation(_ url: URL) {
        session?.socket.connect(withUrl: url)
    }

    func onDisconnect() {
        clearActiveSession()
    }

    // MARK: - Private methods
    private func clearActiveSession() {
        session?.terminateSession()
        session = nil
        eventQueue = nil
    }

}


//extension ThreadSafeQueue<T> {
//
//    /// Removes all of the elements from this queue.
//    func copy() -> ThreadSafeQueue<T> {
//        ThreadSafeQueue(
//    }
//}
