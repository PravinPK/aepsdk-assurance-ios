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

class AssuranceSession {
    let assuranceExtension: Assurance
    var pinCodeScreen: SessionAuthorizingUI?
    lazy var socket: SocketConnectable  = {
            return WebViewSocket(withListener: self)
    }()

    /// Initializer with instance of  `Assurance` extension
    init(_ assuranceExtension: Assurance) {
        self.assuranceExtension = assuranceExtension
    }

    /// Called when a valid assurance deeplink url is received from the startSession API
    /// Calling this method will attempt to display the pincode screen for session authentication
    ///
    /// Thread : Listener thread from EventHub
    func startSession() {
        let pinCodeScreen = iOSPinCodeScreen.init(withExtension: assuranceExtension)
        self.pinCodeScreen = pinCodeScreen

        pinCodeScreen.show(callback: { [weak self] socketURL, error in
            if let error = error {
                self?.handleConnectionError(error: error, closeCode: nil)
                return
            }

            guard let socketURL = socketURL else {
                Log.debug(label: AssuranceConstants.LOG_TAG, "SocketURL to connect to session is empty. Ignoring to start Assurance session.")
                return
            }

            Log.debug(label: AssuranceConstants.LOG_TAG, "Attempting to make a socket connection with URL : \(socketURL.absoluteString)")
            // todo
            //self?.socket.connect(withUrl: socketURL)
            pinCodeScreen.connectionInitialized()
        })
    }

    func sendEvent(_ assuranceEvent: AssuranceEvent) {
        // coming soon
    }

    func handleConnectionError(error: AssuranceConnectionError, closeCode: Int?) {
        // coming soon
    }

    func addClientLog(_ message: String, visibility: AssuranceClientLogVisibility) {
        // coming soon
    }
    
    func terminateSession() {
        // coming soon
    }

}
