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
import WebKit

class iOSPinCodeScreen: SessionAuthorizingUI {
    var displayed: Bool = false
    var fullscreenMessage: FullscreenPresentable?
    var fullscreenWebView: WKWebView?
    var presentationDelegate: AssurancePresentationDelegate

    /// Initializer
    required init(withPresentationDelegate presentationDelegate: AssurancePresentationDelegate) {
        self.presentationDelegate = presentationDelegate
    }

    /// Invoke this during start session to display the pinCode screen.
    func show() {
        // Use the UIService to create a fullscreen message with the `PinDialogHTML` and show to the user.
        fullscreenMessage = ServiceProvider.shared.uiService.createFullscreenMessage(payload: String(bytes: PinDialogHTML.content, encoding: .utf8) ?? "", listener: self, isLocalImageUsed: false)
        fullscreenMessage?.show()
    }

    /// Invoked when the a socket connection is initialized.
    func sessionInitialized() {
        fullscreenWebView?.evaluateJavaScript("showLoading();", completionHandler: nil)
    }

    /// Invoked when the a successful socket connection is established with a desired assurance session.
    func sessionConnected() {
        fullscreenMessage?.dismiss()
    }

    /// Invoked when the a successful socket connection is terminated.
    func sessionDisconnected() {
        fullscreenMessage?.dismiss()
    }

    /// Invoked when the a socket connection is failed.
    /// - Parameters
    ///     - error - an `AssuranceSocketError` explaining the reason why the connection failed
    ///     - shouldShowRetry - boolean indication if the retry button on the pinpad button should still be shown
    func sessionConnectionFailed(withError error: AssuranceConnectionError) {
        Log.debug(label: AssuranceConstants.LOG_TAG, String(format: "Assurance connection establishment failed. Error : %@, Description : %@", error.info.name, error.info.description))
        let jsFunctionCall = String(format: "showError('%@','%@', %d);", error.info.name, error.info.description, error.info.shouldRetry)
        fullscreenWebView?.evaluateJavaScript(jsFunctionCall, completionHandler: nil)
    }

}
