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
    var csvFileOut: URL?
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

            var record: [Field] = []
            var dataArray = Array(data.components(separatedBy: "\r"))
            if dataArray.count == 1 {
                dataArray = Array(data.components(separatedBy: "\n"))
            }

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
                        let field = Field(text: row[quotedRange].replacingOccurrences(of: "\"\"", with: "\""))
                        record.append(field)

                        // TODO: Distinguish secondary long form questions
                        // TODO: Make this a method
                        if index != 0 && field.text.count >= Survey.primaryLongFormCount {
                            if !primaryLongFormColumns.contains(columnIndex) {
                                primaryLongFormColumns.append(columnIndex)
                            }
                        }

                    // tab?
                    } else if let range = Range(match.range(at: 2), in: row) {
                        let field = Field(text: row[range].trimmingCharacters(in: .whitespaces))
                        record.append(field)
                        // TODO: Distinguish secondary long form questions
                        // TODO: Make this a method
                        if index != 0 && field.text.count >= Survey.primaryLongFormCount {
                            if !primaryLongFormColumns.contains(columnIndex) {
                                primaryLongFormColumns.append(columnIndex)
                            }
                        }
                    }
                    // Track column
                    if !rows.isEmpty {
                        let numColumns = rows[0].fields.count
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
                        // TODO: Localization
                        let phoneIndex = record.firstIndex(where: { $0.text.lowercased() == "email" })
                        let emailIndex = record.firstIndex(where: { $0.text.lowercased() == "phone" })

                        var row = Row(id: index, fields: record)
                        row.phoneColumn = phoneIndex
                        row.emailColumn = emailIndex
                        rows.append(row)

                        stop.pointee = true
                        record = []
                    default: // comma, newline, etc
                        break
                    }
                }
            }
            // TODO: debug empty first column
            for (i, _) in rows.enumerated() {
                // for some reason, the header row is unaffected
                if i != 0 {
                    // remove the blank field at 0
                    rows[i].fields.remove(at: 0)
                }
            }
        } catch {
            print("Error decoding file: \(error)")
        }
    }

    mutating func sort() {
        self.rows.sort(by: {$0.score > $1.score})
    }

    mutating func csvString(to filePath: String?) {
        var outString = ""
        for (rowIndex, row) in rows.enumerated() {
            var thisRow = row

            guard var lastPosition = row.fields.last else {
                print("couldn't get last position of row")
                return
            }

            for (fieldIndex, field) in row.fields.enumerated() {

                thisRow.fields[fieldIndex].text = "\"\(field.text)\""
                self.rows[rowIndex].fields.remove(at: fieldIndex)
                // changed fieldIndex to thisFieldIndex to try and write cells appropriately
                self.rows[rowIndex].fields.insert(thisRow.fields[fieldIndex], at: fieldIndex)

            }
            // CR(\r)LF(\n)
            lastPosition.text.append("\r\n")

            guard let lastIndex = row.fields.lastIndex(where: {$0 == row.fields.last}) else {
                print("Couldn't get last position in row")
                continue
            }

            self.rows[rowIndex].fields.remove(at: lastIndex)
            self.rows[rowIndex].fields.append(lastPosition)

            let fieldsText: [String] = rows[rowIndex].fields.map { $0.text }
            outString.append(fieldsText.joined(separator: ","))
        }
        do {
            guard let filePath = filePath else {
                print("couldn't get survey's file path")
                return
            }
            let fileURL = URL(fileURLWithPath: filePath)
            try outString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("error writing file: \(error)")
        }
    }
}
