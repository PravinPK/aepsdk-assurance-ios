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

class iOSStatusUI {
    var assuranceSession: AssuranceSession
    var floatingButton: FloatingButtonPresentable?
    var fullScreenMessage: FullscreenPresentable?
    var webView: WKWebView?
    var clientLogQueue: ThreadSafeQueue<AssuranceClientLogMessage>

    required init(withSession assuranceSession: AssuranceSession) {
        self.assuranceSession = assuranceSession
        self.clientLogQueue = ThreadSafeQueue(withLimit: 100)
    }

    func display() {
        if let _ = floatingButton {
            return
        }

        if fullScreenMessage == nil {
            self.fullScreenMessage = ServiceProvider.shared.uiService.createFullscreenMessage(payload: String(bytes: StatusInfoHTML.content, encoding: .utf8)!, listener: self, isLocalImageUsed: false)
        }

        floatingButton = ServiceProvider.shared.uiService.createFloatingButton(listener: self)
        floatingButton?.setInitial(position: FloatingButtonPosition.topRight)
        floatingButton?.show()
    }

    func remove() {
        self.floatingButton?.dismiss()
        self.floatingButton = nil
        self.fullScreenMessage = nil
        self.webView = nil
    }

    func updateForSocketConnected() {
        addClientLog("Assurance connection established.", visibility: .low)
        floatingButton?.setButtonImage(imageData: Data(bytes: ActiveIcon.content, count: ActiveIcon.content.count))
    }

    func updateForSocketInActive() {
        addClientLog("Assurance disconnected. Attempting to reconnect..", visibility: .low)
        floatingButton?.setButtonImage(imageData: Data(bytes: InactiveIcon.content, count: InactiveIcon.content.count))
    }
    
    func addClientLog(_ message: String, visibility: AssuranceClientLogVisibility) {
        clientLogQueue.enqueue(newElement: AssuranceClientLogMessage(withVisibility: visibility, andMessage: message))
        updateLogUI()
    }

    func updateLogUI() {
        guard let webView = webView else {
            return
        }

        while clientLogQueue.size() > 0 {
            guard let logMessage = clientLogQueue.dequeue() else {
                return
            }

            var cleanMessage = logMessage.message.replacingOccurrences(of: "\\", with: "\\\\")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\"", with: "\\\"")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\n", with: "<br>")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\t", with: "&nbsp;&nbsp;&nbsp;&nbsp;")
            DispatchQueue.main.async {
                let logCommand = String(format: "addLog(\"%d\", \"%@\");", logMessage.visibility.rawValue, logMessage.message)
                webView.evaluateJavaScript(logCommand, completionHandler: { _, error in
                    if let error = error {
                        print("Error Happened \(error.localizedDescription)")
                    }

                })
            }
        }

    }

}
