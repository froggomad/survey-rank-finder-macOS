//
//  Row.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/14/20.
//

import Foundation

struct Row: Codable {
    var fields: [Field]
    var score: Int {
        let longFormFields = fields.filter { $0.isLongForm }
        let scores = longFormFields.map { $0.score }
        // add scores together
        return scores.reduce(0, +)
    }
}
