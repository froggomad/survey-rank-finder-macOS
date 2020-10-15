//
//  Survey_VIP_FinderUITests.swift
//  Survey VIP FinderUITests
//
//  Created by Kenny on 10/10/20.
//

import XCTest
@testable import Survey_VIP_Finder

class Survey_VIP_FinderUITests: XCTestCase {

    var surveyViewController: SurveyViewController!

    override func setUp() {
        super.setUp()
        let testBundle = Bundle(for: type(of: self))
        let storyboard = NSStoryboard(name: "Main", bundle: testBundle)
        surveyViewController = storyboard.instantiateController(withIdentifier: "SurveyViewController") as? SurveyViewController
        // create the view
        _ = surveyViewController.view
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

    func testCanOpenFileDialog() {
        let app = XCUIApplication()
        app.launch()
        let window = XCUIApplication().windows["Survey VIP Finder"]
        let openButton = window.toolbars.buttons["Open"]
        openButton.click()
        let dialog = app.dialogs["Open a .csv file"]
        XCTAssertTrue(dialog.exists)

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
