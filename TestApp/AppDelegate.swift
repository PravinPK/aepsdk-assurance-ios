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

import AEPAnalytics
import AEPAssurance
import AEPCore
import AEPEdge
import AEPEdgeConsent
import AEPEdgeIdentity
import AEPIdentity
import AEPLifecycle
import AEPPlaces
import AEPSignal
import AEPTarget
import AEPUserProfile
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        MobileCore.setLogLevel(.trace)
//        let extensions = [AEPIdentity.Identity.self,
//                          Lifecycle.self,
//                          Signal.self,
//                          Edge.self,
//                          Consent.self,
////                          Analytics.self,
//                          AEPEdgeIdentity.Identity.self,
//                          Target.self,
//                          Consent.self,
//                          UserProfile.self,
//                          Assurance.self,
//                          Places.self
//        ]
//
//        MobileCore.registerExtensions(extensions, {
//            MobileCore.configureWith(appId: "94f571f308d5/d3131a927d4c/launch-1b4cb493d882-development")
//        })
        
        
        
        
        // Onboarding Install Instructions
        // No deeplink setup required
        let extensions = [AEPIdentity.Identity.self,
                          Lifecycle.self,
                          Assurance.self]
        MobileCore.registerExtensions(extensions, {
            MobileCore.configureWith(appId: "launch-ENbc59c20ad405417a9622ae1e22f6a13e-development")
            MobileCore.lifecycleStart(additionalContextData: nil)
        })
        
        Assurance.startSession(url: URL(string: "griffon://?adb_validation_sessionid=e2e64f7d-56d9-4900-b821-ea1a446d2500"))
        
    

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Assurance.startSession(url: url)
        return true
    }

}
