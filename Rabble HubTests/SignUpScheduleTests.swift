//
//  SignUpScheduleTests.swift
//  Rabble HubTests
//
//  Created by aljon antiola on 5/24/24.
//
//

import XCTest
@testable import Rabble_Hub

final class SignUpScheduleTests: XCTestCase {

    var viewController: SignUpScheduleViewController!

    override func setUp() {
        super.setUp()
        // Initialize the view controller from the storyboard
        let storyboard = UIStoryboard(name: "SignUpView", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "SignUpScheduleViewController") as? SignUpScheduleViewController
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }


    func testWholeDaySwitchButtonChanged() {
        // Given
        viewController.wholeDaySwitchButton.isOn = true
        
        // When
        viewController.wholeDaySwitchButtonChanged(viewController.wholeDaySwitchButton as Any)
        
        // Then
        XCTAssertTrue(viewController.nextButton.isEnabled)
        
        // When
        viewController.wholeDaySwitchButton.isOn = false
        viewController.wholeDaySwitchButtonChanged(viewController.wholeDaySwitchButton as Any)
        
        // Then
        XCTAssertFalse(viewController.nextButton.isEnabled)
    }

    func testScheduleSegmentedControlTap_AllTheTime() {
        // Given
        viewController.scheduleSegmentedControlButton.selectedSegmentIndex = 0
        
        // When
        viewController.scheduleSegmentedControlTap(viewController.scheduleSegmentedControlButton as Any)
        
        // Then
        XCTAssertEqual(viewController.segmentContentViewConstraintHeight.constant, viewController.defaultHeight)
        XCTAssertFalse(viewController.segmentFirstView.isHidden)
        XCTAssertTrue(viewController.tableViewContainerView.isHidden)
        XCTAssertEqual(viewController.selectedStoreHoursType, .allTheTime)
    }

    func testScheduleSegmentedControlTap_MonToFri() {
        // Given
        viewController.scheduleSegmentedControlButton.selectedSegmentIndex = 1
        
        // When
        viewController.scheduleSegmentedControlTap(viewController.scheduleSegmentedControlButton as Any)
        
        // Then
        XCTAssertEqual(viewController.segmentContentViewConstraintHeight.constant, 617)
        XCTAssertTrue(viewController.segmentFirstView.isHidden)
        XCTAssertFalse(viewController.tableViewContainerView.isHidden)
        XCTAssertEqual(viewController.selectedStoreHoursType, .monToFri)
    }

    func testScheduleSegmentedControlTap_Custom() {
        // Given
        viewController.scheduleSegmentedControlButton.selectedSegmentIndex = 2
        
        // When
        viewController.scheduleSegmentedControlTap(viewController.scheduleSegmentedControlButton as Any)
        
        // Then
        XCTAssertEqual(viewController.segmentContentViewConstraintHeight.constant, 864)
        XCTAssertTrue(viewController.segmentFirstView.isHidden)
        XCTAssertFalse(viewController.tableViewContainerView.isHidden)
        XCTAssertEqual(viewController.selectedStoreHoursType, .custom)
    }
}
