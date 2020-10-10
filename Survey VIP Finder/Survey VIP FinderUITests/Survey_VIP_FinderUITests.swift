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
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
