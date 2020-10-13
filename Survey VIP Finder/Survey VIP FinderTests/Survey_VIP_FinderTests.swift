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

    func testCanCreate100ColumnsWithCorrectIds() {
        // 100 / 26 == 3r22
        // leaving us resting on the 4th iteration of W
        let finalIdentifier = "WWWW"
        let numColumns = 100
        let letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        /// repeat the letter this number of times for the column's identifier
        var columnTitle = ""
        for cellIndex in 0...numColumns {
            let numLetters: Int = cellIndex / letters.count + 1
            let letterIndex = cellIndex % letters.count
            columnTitle = String(repeating: letters[letterIndex], count: numLetters).uppercased()
        }
        XCTAssertEqual(columnTitle, finalIdentifier)
    }


}
