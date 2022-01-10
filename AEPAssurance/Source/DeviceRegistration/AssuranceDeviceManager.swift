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

import Foundation
import UIKit


class AssuranceDeviceManager {
    private let registrationAPI = AssuranceDeviceAPI()
    private var registrationUI : AssuranceDeviceRegistrationUI?
    private let parentExtension : Assurance
    
    init(assurance : Assurance) {
        parentExtension = assurance;
    }
    
    
    func detectShakeGesture() {
        DispatchQueue.main.async {
            self.registrationUI = AssuranceDeviceRegistrationUI(deviceManager: self)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleShakeGesture),
                                               name: NSNotification.Name(AssuranceConstants.ShakeGesture.NOTIFICATION_KEY),
                                               object: nil)
    }
    
    
        
    @objc private func handleShakeGesture() {
        parentExtension.shouldProcessEvents = true
        parentExtension.invalidateTimer()
        DispatchQueue.main.async {
            self.registrationUI?.showPrompt()
        }
        
    }
    
    func createDevice() {
        registrationAPI.registerDevice(clientID: parentExtension.clientID, orgID: parentExtension.getURLEncodedOrgID() ?? "changeme", callback: { result in
            
            switch result {
            case .success(_):
                self.registrationUI?.onSuccessfulDeviceRegistration()
                self.checkDeviceStatus()
                break
            case .failure(_):
                self.registrationUI?.onFailedDeviceRegistration()
            }
            
        })
    }
    
    func checkDeviceStatus() {
        
        guard let orgID = parentExtension.getURLEncodedOrgID() else {
            // log here
            return
        }
        registrationAPI.getDeviceStatus(clientID: parentExtension.clientID, orgID: orgID, callback: { [self] result in
            switch result {
            case .success((let sessionId, let token)):
                
                self.registrationUI?.onSuccessfulApproval()
                deleteDevice()
                //wss://connect%@.griffon.adobe.com/client/v1?sessionId=%@&token=%@&orgId=%@&clientId=%@
                let socketURL = String(format: AssuranceConstants.BASE_SOCKET_URL,
                                       self.parentExtension.environment.urlFormat,
                                       sessionId,
                                       token,
                                       orgID,
                                       self.parentExtension.clientID)

                guard let url = URL(string: socketURL) else {
                    return
                }
                
                self.parentExtension.assuranceSession?.connectToSocketWith(url: url)
                break
            case .failure(_):
                self.registrationUI?.onFailedApproval()
                    //self.registrationUI?.showStatus(status: "API failure to check the device status.")
                break
            }
            
        })
    }
    
    func deleteDevice() {
        guard let orgID = parentExtension.getURLEncodedOrgID() else {
            // log here
            return
        }
        
        registrationAPI.deleteDevice(clientID: parentExtension.clientID, orgID: orgID, callback: { [self] result in
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


#if DEBUG
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(motion == UIEvent.EventSubtype.motionShake) {
            NotificationCenter.default.post(name: NSNotification.Name(AssuranceConstants.ShakeGesture.NOTIFICATION_KEY),
                                            object: nil)
        }
    }
}
#endif
