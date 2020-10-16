//
//  Row.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/14/20.
//

import Foundation

struct Row: Codable {
    // MARK: - Properties -
    var id: Int
    var emailColumn: Int?
    var phoneColumn: Int?

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

    // MARK: - Methods -
    mutating func addFields() {
        fields.append(addSMIQField())
        fields.append(addEmailandPhoneField())
        fields.append(addScoreField())
    }

    private var SMIQScore: Int? {
        var longFields = fields.filter { $0.isLongForm }
        if !longFields.isEmpty {
            longFields.sort { $0.score > $1.score }

            let highScore = longFields[0].score

            return highScore
        }

        return nil
    }

    private func addSMIQField() -> Field {
        let highScore = SMIQScore ?? 0

        let text = String(highScore)
        return Field(text: text)
    }

    private func addEmailandPhoneField() -> Field {
        var emailValue: String = ""
        var phoneValue: String = ""

        if let emailColumn = emailColumn {
            emailValue = fields[emailColumn].text
        }

        if let phoneColumn = phoneColumn {
            phoneValue = fields[phoneColumn].text
        }

        return Field(text: "\(emailValue) \n \(phoneValue)")
    }

    private func addScoreField() -> Field {
        let text = String(score)
        return Field(text: text)
    }
}
