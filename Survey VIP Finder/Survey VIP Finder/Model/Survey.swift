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

    lazy var csvFileUrl: URL = URL(fileURLWithPath: filePath)
    // 10r, 27c
    mutating func read() {
        do {
            let data = try String(contentsOf: csvFileUrl)
            // https://stackoverflow.com/questions/49206930/csv-parsing-swift-4
            // split rows by comma, ignoring commas in quotes
            let pattern = "[ \t]*(?:\"((?:[^\"]|\"\")*)\"|([^,\"\r\\n]*))[ \t]*(,|\r\\n?|\\n|$)"
            let regex = try! NSRegularExpression(pattern: pattern)

            var record: [String] = []
            
            for row in data.components(separatedBy: "\r") {
                // apply rules to each block matched using the above regex
                regex.enumerateMatches(in: row, options: .anchored, range: NSRange(0..<row.utf16.count)) {match, flags, stop in
                    guard let match = match else {
                        // TODO: Alert user
                        print("unable to match the pattern for this csv file")
                        return
                    }
                    // inside quotes
                    if let quotedRange = Range(match.range(at: 1), in: row) {
                        let field = row[quotedRange].replacingOccurrences(of: "\"\"", with: "\"")
                        record.append(field)
                    // tab?
                    } else if let range = Range(match.range(at: 2), in: row) {
                        let field = row[range].trimmingCharacters(in: .whitespaces)
                        record.append(field)
                    }
                    // ","
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
        } catch {
            print(error)
        }
    }

    func csvString() {
        // append "/r" to last position of each row
        // csvData.join(",")
    }
}
