/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http:www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

@testable import AEPAssurance
import Foundation
import XCTest
import AEPServices

class AssurancePresentationTests: XCTestCase {
    
    // testing class
    var presentation: AssurancePresentation!
    
    // mocked dependencies
    let runtime = TestableExtensionRuntime()
    var mockStateManager: MockStateManager!
    var mockSessionOrchestrator: MockSessionOrchestrator!
    var mockStatusUI : MockStatusUI!
    var mockPinPad : MockPinPad!
        
    override func setUp() {
        mockStateManager = MockStateManager(runtime)
        mockSessionOrchestrator = MockSessionOrchestrator(stateManager: mockStateManager)
        mockStatusUI = MockStatusUI(withSessionOrchestrator: mockSessionOrchestrator)
        mockPinPad = MockPinPad(withPresentationDelegate: mockSessionOrchestrator)
        presentation = AssurancePresentation(sessionOrchestrator: mockSessionOrchestrator)
        presentation.statusUI = mockStatusUI
        presentation.pinCodeScreen = mockPinPad
    }
    
    func test_addClientLog() {
        // test
        presentation.addClientLog("testString", visibility: .normal)
        
        // verify
        XCTAssertTrue(mockStatusUI.addClientLogCalled)
        XCTAssertEqual("testString", mockStatusUI.addClientLogMessage)
        XCTAssertEqual("testString", mockStatusUI.addClientLogMessage)
    }
    
    func test_onSessionConnected() {
        // setup
        mockPinPad.displayed = true
        
        // test
        presentation.sessionConnected()
        
        // verify that the pinpad screen is removed
        XCTAssertTrue(mockPinPad.onSessionConnectedCalled)
        
        // verify that the status screen is display with connected status
        XCTAssertTrue(mockStatusUI.displayCalled)
        XCTAssertTrue(mockStatusUI.updateForSocketConnectedCalled)
    }
    
    func test_onSessionReconnecting() {
        // setup
        mockPinPad.displayed = false
        
        // test
        presentation.sessionReconnecting()

        // verify that the status screen is display with inactive status
        XCTAssertTrue(mockStatusUI.displayCalled)
        XCTAssertTrue(mockStatusUI.updateForSocketInActiveCalled)
    }
    
    func test_onSessionDisconnected() {        
        // test
        presentation.sessionDisconnected()

        // verify that the status screen is display with inactive status
        XCTAssertTrue(mockPinPad.onSessionDisconnectedCalled)
        XCTAssertTrue(mockStatusUI.removeCalled)
    }
    
    func test_onSessionConnectionError_nonRetryable() {
        // setup
        mockPinPad.displayed = true
        
        // test
        presentation.sessionConnectionError(error: .eventLimit)

        // verify
        XCTAssertTrue(mockPinPad.sessionConnectionFailed)
        XCTAssertEqual(.eventLimit, mockPinPad.sessionConnectionFailedError)
        
        // remove the Status UI on nonRetry error
        XCTAssertTrue(mockStatusUI.removeCalled)
    }
    
    func test_onSessionConnectionError_Retryable() {
        // setup
        mockPinPad.displayed = true
        
        // test
        presentation.sessionConnectionError(error: .genericError)

        // verify that the status screen is display with inactive status
        XCTAssertTrue(mockPinPad.sessionConnectionFailed)
        XCTAssertEqual(.genericError, mockPinPad.sessionConnectionFailedError)
        
        // donot remove the Status UI on Retry error
        XCTAssertFalse(mockStatusUI.removeCalled)
    }
        
}
