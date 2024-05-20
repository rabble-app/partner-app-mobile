//
//  MobileInputViewControllerTests.swift
//  Rabble HubTests
//
//  Created by Franz Henri De Guzman on 5/19/24.
//

import XCTest
@testable import Rabble_Hub
@testable import Pods_Rabble_Hub
@testable import Pods_Rabble_HubTests


class MobileInputViewControllerTests: XCTestCase {
    
    var viewController: MobileInputViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "OnboardingView", bundle: Bundle(for: MobileInputViewController.self))
        viewController = storyboard.instantiateViewController(withIdentifier: "MobileInputViewController") as? MobileInputViewController
        viewController.loadViewIfNeeded() // To load the view hierarchy
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testValidatePhoneNumber() {
        // Test with an empty phone number
        viewController.phoneNumberTextfield = UITextField()
        viewController.phoneNumberTextfield.text = ""
        XCTAssertFalse(viewController.validatePhoneNumber(), "Phone number validation should fail for empty input")
        
        // Test with a non-empty phone number
        viewController.phoneNumberTextfield.text = "1234567890"
        XCTAssertTrue(viewController.validatePhoneNumber(), "Phone number validation should pass for non-empty input")
    }
    
    func testValidateTickBox() {
        // Test with tick box not selected
        viewController.isTickBoxSelected = false
        XCTAssertFalse(viewController.validateTickBox(), "Tick box validation should fail when not selected")
        
        // Test with tick box selected
        viewController.isTickBoxSelected = true
        XCTAssertTrue(viewController.validateTickBox(), "Tick box validation should pass when selected")
    }
    
    func testTickBoxButtonTap() {
        // Initial state should be not selected
        XCTAssertFalse(viewController.isTickBoxSelected, "Initial state of tick box should be not selected")
        
        // Simulate tap
        viewController.tickBoxButtonTap(UIButton())
        XCTAssertTrue(viewController.isTickBoxSelected, "Tick box should be selected after tap")
        
        // Simulate another tap
        viewController.tickBoxButtonTap(UIButton())
        XCTAssertFalse(viewController.isTickBoxSelected, "Tick box should be deselected after another tap")
    }
}
