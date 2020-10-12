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
            let rows = data.components(separatedBy: "\r")
            print(rows[0], rows.count)
            // https://stackoverflow.com/questions/49206930/csv-parsing-swift-4
            // split rows by comma, ignoring commas in quotes
            let pattern = "[ \t]*(?:\"((?:[^\"]|\"\")*)\"|([^,\"\r\\n]*))[ \t]*(,|\r\\n?|\\n|$)"
            let regex = try! NSRegularExpression(pattern: pattern)

            var record: [String] = []
            
            for row in rows {
                // apply rules to each block matched using the above regex
                regex.enumerateMatches(in: row, options: .anchored, range: NSRange(0..<row.utf16.count)) {match, flags, stop in
                    guard let match = match else {
                        // TODO: Alert user
                        print("unable to match the pattern for this csv file")
                        return
                    }
                    if let quotedRange = Range(match.range(at: 1), in: row) {
                        let field = row[quotedRange].replacingOccurrences(of: "\"\"", with: "\"")
                        record.append(field)
                    } else if let range = Range(match.range(at: 2), in: row) {
                        let field = row[range].trimmingCharacters(in: .whitespaces)
                        record.append(field)
                    }
                    let separator = row[Range(match.range(at: 3), in: row)!]
                    switch separator {
                    case "": //end of text
                        cellData.append(record)
                        stop.pointee = true
                    case ",": //comma
                        break
                    default: //newline
                        cellData.append(record)
                        record = []
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
