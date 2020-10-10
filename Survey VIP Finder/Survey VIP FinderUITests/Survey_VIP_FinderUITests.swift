//
//  Survey_VIP_FinderUITests.swift
//  Survey VIP FinderUITests
//
//  Created by Kenny on 10/10/20.
//

import XCTest
@testable import Survey_VIP_Finder

class Survey_VIP_FinderUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCanInteractWithToolbar() {
        let app = XCUIApplication()
        app.launch()

        let window = XCUIApplication().windows["Survey VIP Finder"]
        let sortButton = window.toolbars.buttons["Sort"]
        let openButton = window.toolbars.buttons["Open"]
        let refreshButton = window.toolbars.buttons["Refresh"]

        XCTAssertTrue(sortButton.isHittable)
        XCTAssertTrue(openButton.isHittable)
        XCTAssertTrue(refreshButton.isHittable)
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
