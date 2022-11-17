/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import UIKit

struct QuickConnectionError: Error {
    let message: String
}

class QuickConnectManager {
    typealias QuickConnectCallback = ((Result< URL, QuickConnectionError>) -> Void)
    
    private let quickConnectService = QuickConnectService()
    private lazy var quickConnectView = QuickConnectView(manager: self)
    private let parentExtension: Assurance
    private var quickConnectCallback : QuickConnectCallback?

    init(assurance: Assurance) {
        parentExtension = assurance
    }
    

    func startQuickConnectSession(withCallback callback: @escaping QuickConnectCallback) {
        quickConnectCallback = callback
        DispatchQueue.main.async {
             self.quickConnectView.show()
        }
    }
    
    func createDevice() {
        quickConnectService.registerDevice(clientID: parentExtension.stateManager.clientID, orgID: parentExtension.stateManager.getURLEncodedOrgID() ?? "changeme", callback: { result in
             
             switch result {
             case .success(_):
                 self.quickConnectView.waitingState()
                 self.checkDeviceStatus()
                 break
             case .failure(_):
                 self.quickConnectView.onFailedDeviceRegistration()
             }
             
         })
     }
    
    func checkDeviceStatus() {
        
        guard let orgID = parentExtension.stateManager.getURLEncodedOrgID() else {
            // log here
            return
        }
        quickConnectService.getDeviceStatus(clientID: parentExtension.stateManager.clientID, orgID: orgID, callback: { [self] result in
            switch result {
            case .success((let sessionId, let token)):
                
                deleteDevice()
                self.quickConnectView.onSuccessfulApproval()
                //wss://connect%@.griffon.adobe.com/client/v1?sessionId=%@&token=%@&orgId=%@&clientId=%@
                let socketURL = String(format: AssuranceConstants.BASE_SOCKET_URL,
                                       AssuranceEnvironment.prod.urlFormat,
                                       sessionId,
                                       token,
                                       orgID,
                                       self.parentExtension.stateManager.clientID)

                guard let url = URL(string: socketURL) else {
                    return
                }
                
                quickConnectCallback!(.success(url))
                break
            case .failure(_):
                self.quickConnectView.onFailedApproval()
                    //self.registrationUI?.showStatus(status: "API failure to check the device status.")
                break
            }
            
        })
    }
    
    func deleteDevice() {
        guard let orgID = parentExtension.stateManager.getURLEncodedOrgID() else {
            // log here
            return
        }
        
        quickConnectService.deleteDevice(clientID: parentExtension.stateManager.clientID, orgID: orgID, callback: { [] result in
        switch result {
            case .success(_):
                // log here
                break
            case .failure(_):
                // log here\
                break
            }
        })

    }
    
}


//#if DEBUG
//extension UIWindow {
//    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if(motion == UIEvent.EventSubtype.motionShake) {
//            NotificationCenter.default.post(name: NSNotification.Name(AssuranceConstants.QuickConnect.SHAKE_NOTIFICATION_KEY),
//                                            object: nil)
//        }
//    }
//}
//#endif
