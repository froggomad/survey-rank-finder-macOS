//
//  Survey_VIP_FinderTests.swift
//  Survey VIP FinderTests
//
//  Created by Kenny on 10/12/20.
//

import XCTest
@testable import Survey_VIP_Finder

class Survey_VIP_FinderTests: XCTestCase {

    func testCSVParsing() throws {
        #warning("Adjust this path to a local file. Maybe this should be pulled from the bundle")
        let filePath = "/Users/kenny/Xcode Projects/Xcode projects/Paul_Solt/ORIGINAL FILES/Delicious Hario V60 Survey/Raw Data - First Look - 6-2-20/2020-6-2 Delicious Hario V60 SMIQ Beta Test Interest.csv"
        var survey = Survey(filePath: filePath)
        survey.read()

        XCTAssertEqual(survey.cellData.count, 10)
        XCTAssertEqual(survey.cellData[0].count, 27)
    }



}
