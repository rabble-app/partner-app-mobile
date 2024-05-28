//
//  SignUpViewControllerTests.swift
//  Rabble HubTests
//
//  Created by Franz Henri De Guzman on 5/22/24.
//

import XCTest
import Moya
@testable import Rabble_Hub

class SignUpViewControllerTests: XCTestCase {

    var viewController: SignUpViewController!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        let storyboard = UIStoryboard(name: "SignUpView", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
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
        
        XCTAssertEqual(viewController.navigationController?.navigationBar.isHidden, true)
    }

//    func testSaveStoreProfile() {
//        let expectation = self.expectation(description: "Save Store Profile")
//
//        // Setup mock data
//        viewController.storeName.text = "Test Store"
//        viewController.postalCode.text = "12345"
//        viewController.city.text = "Test City"
//        viewController.street.text = "Test Street"
//        viewController.direction.text = "Test Direction"
//        viewController.storeType.text = "Test Store Type"
//        viewController.shelfSpace.text = "10"
//        viewController.dryStorageSpace.text = "20"
//
//        // Mock the API response
//        let response = Response(statusCode: 200, data: """
//            {
//                "statusCode": 200,
//                "message": "Success",
//                "data": {
//                    "id": "1",
//                    "userId": "1",
//                    "name": "Test Store",
//                    "postalCode": "12345",
//                    "stripeConnectId": "123",
//                    "city": "Test City",
//                    "streetAddress": "Test Street",
//                    "direction": "Test Direction",
//                    "storeType": "Test Store Type",
//                    "shelfSpace": "10",
//                    "dryStorageSpace": "20",
//                    "createdAt": "2024-05-21T00:00:00.000Z",
//                    "updatedAt": "2024-05-21T00:00:00.000Z"
//                }
//            }
//        """.data(using: .utf8)!)
//        
//        let provider = MoyaProvider<RabbleHubAPI>(stubClosure: MoyaProvider.immediatelyStub) // Simplified provider creation
//        
//        viewController.apiProvider = provider
//
//        viewController.nextButtonTap(self) // Corrected method call
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            XCTAssertNotNil(StoreManager.shared.store)
//            XCTAssertEqual(StoreManager.shared.store?.name, "")
//            XCTAssertNotNil(self.viewController.presentedViewController as? SignUpProfileViewController)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 5, handler: nil)
//    }
}
