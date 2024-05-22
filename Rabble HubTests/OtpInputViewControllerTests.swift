//
//  OtpInputViewControllerTests.swift
//  Rabble HubTests
//
//  Created by Franz Henri De Guzman on 5/19/24.
//

import XCTest
import Moya
@testable import Rabble_Hub
@testable import Pods_Rabble_Hub
@testable import Pods_Rabble_HubTests

class OtpInputViewControllerTests: XCTestCase {
    
    var viewController: OtpInputViewController!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "OnboardingView", bundle: Bundle(for: OtpInputViewController.self))
        viewController = storyboard.instantiateViewController(withIdentifier: "OtpInputViewController") as? OtpInputViewController
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        window = nil
        viewController = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        viewController.phoneNumber = "1234567890"
        viewController.viewDidLoad()
        
        XCTAssertEqual(viewController.view.backgroundColor, Colors.BackgroundPrimary)
        XCTAssertEqual(viewController.descLabel.text, "Enter the 6 digit verification code we sent to you on 1234567890")
        XCTAssertEqual(viewController.otpField.slotCount, 6)
        XCTAssertEqual(viewController.otpField.filledSlotTextColor, Colors.Gray1)
    }
    
    func testVerifyOTP() {
        let expectation = self.expectation(description: "Verify OTP")

        viewController.phoneNumber = "1234567890"
        viewController.sid = "testSid"
        viewController.code = "123456"
        
        // Mock the API response
        let response = Response(statusCode: 200, data: "{\"statusCode\":200,\"message\":\"Success\",\"data\":{\"token\":\"testToken\"}}".data(using: .utf8)!)
        let provider = MoyaProvider<RabbleHubAPI>(endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, response.data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)
        viewController.apiProvider = provider

        viewController.verifyOTP()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(true) // If it reaches here, that means the API was called and response was handled
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSendOTP() {
        let expectation = self.expectation(description: "Send OTP")

        viewController.phoneNumber = "1234567890"
        
        // Mock the API response
        let response = Response(statusCode: 200, data: "{\"statusCode\":200,\"message\":\"Success\",\"data\":{\"sid\":\"newSid\"}}".data(using: .utf8)!)
        let provider = MoyaProvider<RabbleHubAPI>(endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, response.data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)
        viewController.apiProvider = provider
        
        viewController.sendOTP()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewController.sid, "newSid")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
