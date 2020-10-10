//
//  SurveyTableViewCell.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/9/20.
//

import Cocoa

/// Display information about the current cell
class SurveyTableViewCell: NSTableCellView {
    /// Add information to display in the cell's TextView
    var information: String?

    @IBOutlet var informationLabel: NSTextView!

}
