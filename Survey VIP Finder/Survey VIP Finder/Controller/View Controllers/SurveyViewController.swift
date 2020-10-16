//
//  ViewController.swift
//  Survey VIP Finder
//
//  Created by Kenny on 10/9/20.
//

import Cocoa
/// The app's initial view
class SurveyViewController: NSViewController {
    // MARK: - Outlets -
    @IBOutlet var tableView: NSTableView!

    var loadButton: NSToolbarItem?
    var sortButton: NSToolbarItem?
    var refreshButton: NSToolbarItem?
    var exportButton: NSToolbarItem?

    // MARK: - Properties -
    /// The active survey
    var survey: Survey? {
        didSet {
            sortButton?.action = #selector(sortCSV)
            exportButton?.action = #selector(displayFileDialogAndExportCSV)
        }
    }

    /// Is the CSV being sorted using the 80/20 rule?
    var sorted: Bool = false
    /// Has the window been setup?
    var didSetup: Bool = false
    /// The currently selected CSV file's path
    var filePath: String? {
        didSet {
            displayCSV()
        }
    }

    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        // no need to do setup again if viewWillAppear is called multiple times
        if !didSetup {
            self.view.window?.title = "Survey VIP Finder"
            setupToolbar()
        }
    }

    // MARK: - Setup Views -
    /// Set the ViewController's Toolbar properties
    private func setupToolbar() {
        // setup sort button
        sortButton = getToolbarItem(.sortToolbarButton)
        // setup load button
        loadButton = getToolbarItem(.addToolbarButton)
        loadButton?.action = #selector(loadCSV)
        // setup refresh button
        refreshButton = getToolbarItem(.refreshToolbarButton)

        exportButton = getToolbarItem(.exportToolbarButton)
        didSetup = true
    }

    private func setupTableView() {

        for column in tableView.tableColumns {
            self.tableView.removeTableColumn(column)
        }

        createHeaderTitles()
    }

    // MARK: - CSV Handling -
    func createHeaderTitles() {
        guard survey != nil,
              let cellData = survey?.rows,
              cellData.count > 0 else {
            print("Couldn't get cell data to create columns")
            return
        }

        for (cellIndex, field) in cellData[0].fields.enumerated() {
            let letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
            /// repeat the letter this number of times for the column's identifier
            let numLetters: Int = cellIndex / letters.count + 1
            let letterIndex = cellIndex % letters.count

            let columnTitle = String(repeating: letters[letterIndex], count: numLetters).uppercased()

            switch field.text.lowercased() {
            case "email":
                survey!.emailColumn = cellIndex
            case "phone":
                survey!.phoneColumn = cellIndex
            default:
                break
            }

            let columnId = NSUserInterfaceItemIdentifier(rawValue:"\(cellIndex)")
            let column = NSTableColumn(identifier: columnId)
            column.title = columnTitle

            tableView.addTableColumn(column)
        }

    }

    private func displayCSV() {
        guard let path = filePath else {
            print("File path unavailable")
            return
        }
        survey = Survey(filePath: path)
        survey?.read()

        setupTableView()
        tableView.reloadData()
    }

    /// Parse the loaded CSV file and refresh the tableView
    @objc private func loadCSV() {
        displayFileDialogAndSetPath()
    }

    /// Sort the loaded CSV file using the 80/20 rule
    @objc private func sortCSV() {
        survey?.sort()
        tableView.reloadData()
    }

    /// Load any new information in the current CSV file
    @objc private func refreshCSV() {
        // make sure file is loaded
        // reload using current sorting
    }

    @objc private func displayFileDialogAndExportCSV() {
        survey?.csvString(to: displaySavePanel())
    }

    // MARK: - Helper Methods -

    private func displaySavePanel() -> String? {
        let dialog = NSSavePanel()
        dialog.canCreateDirectories = true
        dialog.showsHiddenFiles = true
        dialog.allowedFileTypes = ["csv"]
        dialog.nameFieldStringValue = ".csv"

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            // the result of the user's action
            // includes filepath if not nil
            guard let result = dialog.url else {
                print("problem retrieving dialog's response")
                return nil
            }
            return result.path
        } else {
            // User cancelled
            return nil
        }
    }

    /// Use an identifier to get a toolbarItem
    /// - Parameter identifier: the toolbarItem's identifier
    /// - Returns: an optional `NSToolbarItem` from the current ViewController
    private func getToolbarItem(_ identifier: NSToolbarItem.Identifier) -> NSToolbarItem? {
        // return the first NSToolbarItem matching the passed in identifier
        self.view.window?.toolbar?.items.filter {
            $0.itemIdentifier == identifier
        }.first
    }

    private func displayFileDialogAndSetPath() {
        filePath = displayFileDialog()
    }

    private func displayFileDialog() -> String? {
        let dialog = NSOpenPanel();
        dialog.showsHiddenFiles        = true;
        // this may not be necessary since we're explicitly allowing .csv only
        dialog.canChooseDirectories    = false;
        // probably not necessary to allow, but couldn't hurt and might be useful
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["csv"];
        // present the dialog and handle what the user does
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            // the result of the user's action
            // includes filepath if not nil
            guard let result = dialog.url else {
                print("problem retrieving dialog's response")
                return nil
            }
            return result.path
        } else {
            // User cancelled
            return nil
        }
    }



}
// MARK: - TableView DataSource and Delegate -
extension SurveyViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        survey?.rows.count ?? 0
    }
}

extension SurveyViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier.rawValue,
              let title = tableColumn?.title else {
            print("couldn't load data for cell view")
            return nil
        }
        guard let index = Int(identifier) else {
            print("Couldn't create index from identifier")
            return nil
        }

        guard row < survey?.rows.count ?? 0 - 1,
              index < survey?.rows[row].fields.count ?? 0 - 1,
              let field = survey?.rows[row].fields[index] else {
            print("Couldn't find field at row: \(row) column: \(index)/\(title)")
            return nil
        }

        let cellId = NSUserInterfaceItemIdentifier(rawValue: "\(row):\(title)")
        var cell = tableView.makeView(withIdentifier: cellId, owner: self) as? NSTextField
        if cell == nil {
            cell = NSTextField(labelWithString: field.text)
            tableColumn?.minWidth = 150
            if field.isLongForm {
                tableColumn?.width = 500
            }
            cell!.identifier = cellId // allows this new cell to be reused
        }
        return cell
    }

    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        let columnId = tableView.tableColumns.filter { $0.identifier == tableColumn?.identifier }[0].identifier.rawValue
        guard let columnIndex = Int(columnId) else {
            print("problem converting \(columnId) to Int")
            return ""
        }
        tableView.editColumn(columnIndex, row: row, with: nil, select: true)
        let textField = tableView.tableColumns[columnIndex].dataCell(forRow: row) as? NSTextField
        return textField?.stringValue

    }
}

// MARK: - Toolbar Identifiers -
// Toolbar button identifiers
extension NSToolbarItem.Identifier {
    static let addToolbarButton = NSToolbarItem.Identifier("addToolbarButton")
    static let sortToolbarButton = NSToolbarItem.Identifier("sortToolbarButton")
    static let refreshToolbarButton = NSToolbarItem.Identifier("refreshToolbarButton")
    static let exportToolbarButton = NSToolbarItem.Identifier("exportToolbarButton")
}
