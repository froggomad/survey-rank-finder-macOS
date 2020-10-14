//
//  Field.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/14/20.
//

import Foundation

struct Field: Codable, Equatable {
    var text: String
    var score: Int
    var isLongForm: Bool

    init(text: String) {
        self.text = text
        self.score = text.count
        self.isLongForm = score >= Survey.primaryLongFormCount
    }
}
