//
//  SignUpProfileViewControllerTests.swift
//  Rabble HubTests
//
//  Created by Franz Henri De Guzman on 5/22/24.
//

import XCTest
import Moya
@testable import Rabble_Hub

class SignUpProfileViewControllerTests: XCTestCase {

    var viewController: SignUpProfileViewController!
    var window: UIWindow!
    let userDataManager = UserDataManager()
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        let storyboard = UIStoryboard(name: "SignUpView", bundle: Bundle(for: SignUpProfileViewController.self))
        viewController = storyboard.instantiateViewController(withIdentifier: "SignUpProfileViewController") as? SignUpProfileViewController
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        window = nil
        viewController = nil
        super.tearDown()
    }

    func testViewDidLoad() {
        viewController.viewDidLoad()
        // Add additional setup verification if needed
    }

    func testUpdateUserRecord() {
        let expectation = self.expectation(description: "Update User Record")

        // Setup mock data
        viewController.firstName.text = "John"
        viewController.lastName.text = "Doe"
        viewController.email.text = "john.doe@example.com"

        // Mock the API response
        let response = Response(statusCode: 200, data: """
            {
                "statusCode": 200,
                "message": "Success",
                "data": {
                    "id": "1",
                    "phone": "1234567890",
                    "email": "john.doe@example.com",
                    "firstName": "John",
                    "lastName": "Doe",
                    "postalCode": "12345",
                    "stripeCustomerId": "cust_123",
                    "imageUrl": null,
                    "role": "user",
                    "createdAt": "2024-05-21T00:00:00.000Z",
                    "updatedAt": "2024-05-21T00:00:00.000Z"
                }
            }
        """.data(using: .utf8)!)
        
        let provider = MoyaProvider<RabbleHubAPI>(endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, response.data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)
        
        viewController.apiProvider = provider

        viewController.updateUserRecord()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.userDataManager.getUserData()?.id)
            XCTAssertEqual(self.userDataManager.getUserData()?.firstName, "John")
            XCTAssertEqual(self.userDataManager.getUserData()?.lastName, "Doe")
            XCTAssertEqual(self.userDataManager.getUserData()?.email, "john.doe@example.com")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNextButtonTap() {
        let expectation = self.expectation(description: "Next Button Tap")

        // Setup mock data
        viewController.firstName.text = "John"
        viewController.lastName.text = "Doe"
        viewController.email.text = "john.doe@example.com"

        // Mock the API response
        let response = Response(statusCode: 200, data: """
            {
                "statusCode": 200,
                "message": "Success",
                "data": {
                    "id": "1",
                    "phone": "1234567890",
                    "email": "john.doe@example.com",
                    "firstName": "John",
                    "lastName": "Doe",
                    "postalCode": "12345",
                    "stripeCustomerId": "cust_123",
                    "imageUrl": null,
                    "role": "user",
                    "createdAt": "2024-05-21T00:00:00.000Z",
                    "updatedAt": "2024-05-21T00:00:00.000Z"
                }
            }
        """.data(using: .utf8)!)
        
        let provider = MoyaProvider<RabbleHubAPI>(endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, response.data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)
        
        viewController.apiProvider = provider

        viewController.nextButtonTap(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.userDataManager.getUserData()?.id)
            XCTAssertEqual(self.userDataManager.getUserData()?.firstName, "John")
            XCTAssertEqual(self.userDataManager.getUserData()?.lastName, "Doe")
            XCTAssertEqual(self.userDataManager.getUserData()?.email, "john.doe@example.com")
            
            XCTAssertNotNil(self.viewController.presentedViewController as? SignUpScheduleViewController)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPreviousStepButtonTap() {
        viewController.previousStepButtonTap(self)
        XCTAssertNil(viewController.presentedViewController)
    }
}
