//
//  Row.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/14/20.
//

import Foundation

struct Row: Codable {
    var id: Int
    var fields: [Field]
    var score: Int {
        if id != 0 {
            let longFormFields = fields.filter { $0.isLongForm }
            let scores = longFormFields.map { $0.score }
            // add scores together
            return scores.reduce(0, +)
        }
        // prevent row from being sorted
        return 999_999_999
    }
}
