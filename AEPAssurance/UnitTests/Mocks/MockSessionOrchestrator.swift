//
// Copyright 2021 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation
@testable import AEPAssurance
import XCTest

class MockSessionOrchestrator : AssuranceSessionOrchestrator {
    
    var expectation: XCTestExpectation?
    required override init(stateManager: AssuranceStateManager) {
        super.init(stateManager: stateManager)
    }

    var createSessionCalled = false
    var createSessionDetails: AssuranceSessionDetails?
    override func createSession(withDetails sessionDetails: AssuranceSessionDetails) {
        createSessionCalled = true
        createSessionDetails = sessionDetails
    }
    
    var canProcessSDKEventsReturnValue = false
    override func canProcessSDKEvents() -> Bool {
        return canProcessSDKEventsReturnValue
    }

    var terminateSessionCalled = false
    override func terminateSession() {
        terminateSessionCalled = true
    }

    var sendEventCalled = false
    var sentEvent: AssuranceEvent?
    override func queueEvent(_ assuranceEvent: AssuranceEvent) {
        expectation?.fulfill()
        sendEventCalled = true
        sentEvent = assuranceEvent
    }

    // MARK: - AssurancePresentationDelegate methods
    
    var pinScreenConnectClickedCalled = false
    var pinScreenConnectClickedPinParameter : String?
    override func pinScreenConnectClicked(_ pin: String) {
        pinScreenConnectClickedCalled = true
        pinScreenConnectClickedPinParameter = pin
    }

    var pinScreenCancelClickedCalled = false
    override func pinScreenCancelClicked() {
        pinScreenCancelClickedCalled = true
    }

    var disconnectClickedCalled = false
    override func disconnectClicked() {
        disconnectClickedCalled = true
    }
    
}

extension AssuranceSessionOrchestrator {
    func setSession() {
        session = nil
    }
}

