//
//  Survey.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/9/20.
//

import Foundation
// FUTURE: save prior results if that's useful (top n customers all time?)

/// Store information about the current Survey
struct Survey: Codable {
    let filePath: String
    var cellData: [[String]] = []
    var rows: [Row] = []

    var primaryLongFormColumns: [Int] = []
    var secondaryLongFormColumns: [Int] = []
    var emailColumn: Int?
    var phoneColumn: Int?

    /// Lower bounds of char count required for primary long form question column
    /// - Note: if any column has an answer with this char count or higher
    /// it will be considered a primary long-form question.
    /// This logic could probably be improved to filter out edge cases...
    /// maybe a certain percentage of answers hit this and the column
    /// is considered a long-form question
    static var primaryLongFormCount = 100
    // TODO: secondaryLongForm logic (count only works for long form overall)

    lazy var csvFileUrl: URL = URL(fileURLWithPath: filePath)
    // 10r, 27c
    mutating func read() {

        /// Track the columnIndex as the loop iterates
        /// - Note: Initialized at -1 due to unforseen edge case (1st column empty)
        var columnIndex = -1

        do {
            let data = try String(contentsOf: csvFileUrl)
            // https://stackoverflow.com/questions/49206930/csv-parsing-swift-4
            // split rows by comma, ignoring commas in quotes
            let pattern = "[ \t]*(?:\"((?:[^\"]|\"\")*)\"|([^,\"\r\\n]*))[ \t]*(,|\r\\n?|\\n|$)"
            let regex = try! NSRegularExpression(pattern: pattern)

            var record: [String] = []
            let dataArray = Array(data.components(separatedBy: "\r"))

            for (index, row) in dataArray.enumerated() {
                // apply rules to each block matched using the above regex
                regex.enumerateMatches(in: row, options: .anchored, range: NSRange(0..<row.utf16.count)) { match, _, stop in
                    guard let match = match else {
                        // TODO: Alert user
                        print("unable to match the pattern for this row")
                        return
                    }
                    // inside quotes
                    if let quotedRange = Range(match.range(at: 1), in: row) {
                        let field = row[quotedRange].replacingOccurrences(of: "\"\"", with: "\"")
                        record.append(field)

                        // TODO: Distinguish secondary long form questions
                        // TODO: Make this a method
                        if index != 0 && field.count >= Survey.primaryLongFormCount {
                            if !primaryLongFormColumns.contains(columnIndex) {
                                primaryLongFormColumns.append(columnIndex)
                            }
                        }
                    // tab?
                    } else if let range = Range(match.range(at: 2), in: row) {
                        let field = row[range].trimmingCharacters(in: .whitespaces)
                        record.append(field)
                        // TODO: Distinguish secondary long form questions
                        // TODO: Make this a method
                        if index != 0 && field.count >= Survey.primaryLongFormCount {
                            if !primaryLongFormColumns.contains(columnIndex) {
                                primaryLongFormColumns.append(columnIndex)
                            }
                        }
                    }
                    // Track column
                    if !cellData.isEmpty {
                        let numColumns = cellData[0].count
                        // Why can't I do a ternary expression here?
                        // left side isn't mutable,expression evaluates to different type
                        let indexOverCount = columnIndex == numColumns
                        
                        if indexOverCount {
                            columnIndex = 0
                        } else {
                            columnIndex += 1
                        }
                    }

                    let separator = row[Range(match.range(at: 3), in: row)!]
                    switch separator {
                    case "":
                        cellData.append(record)
                        stop.pointee = true
                        record = []
                    default: // comma, newline, etc
                        break
                    }
                }
            }
            // TODO: debug empty first column
            for (i, _) in cellData.enumerated() {
                // for some reason, the header row is unaffected
                if i != 0 {
                    // remove the blank field at 0
                    cellData[i].remove(at: 0)
                }
            }
            print(primaryLongFormColumns.sorted(by: {$0<$1}))
            makeRows()
        } catch {
            print("Error decoding file: \(error)")
        }
    }

    // TODO: Refactor into read()
    mutating func makeRows() {
        for dataRow in self.cellData {
            let row = Row(fields: dataRow.map { Field(text: $0) })
            print(row.score)
            self.rows.append(row)
        }
    }

    func csvString() {
        // append "/r" to last position of each row
        // csvData.join(",")
    }
}
