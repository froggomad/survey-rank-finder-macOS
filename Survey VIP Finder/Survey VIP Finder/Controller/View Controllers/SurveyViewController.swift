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

    // MARK: - Properties -
    /// The active survey
    var survey: Survey? {
        didSet {
            // reload TableView
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

    override var representedObject: Any? {
        didSet {

        }
    }

    // MARK: - Setup Views -
    /// Set the ViewController's Toolbar properties
    private func setupToolbar() {
        // setup load button
        loadButton = getToolbarItem(.addToolbarButton)
        loadButton?.action = #selector(loadCSV)
        // setup sort button
        sortButton = getToolbarItem(.sortToolbarButton)

        // setup refresh button
        refreshButton = getToolbarItem(.refreshToolbarButton)
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
        guard let cellData = survey?.cellData,
            cellData.count > 0 else {
            print("Couldn't get cell data to create columns")
            return
        }

        for (cellIndex, _) in cellData[0].enumerated() {
            let letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
            /// repeat the letter this number of times for the column's identifier
            let numLetters: Int = cellIndex / letters.count + 1
            let letterIndex = cellIndex % letters.count

            let columnTitle = String(repeating: letters[letterIndex], count: numLetters).uppercased()
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
        sorted.toggle()
    }

    /// Load any new information in the current CSV file
    @objc private func refreshCSV() {
        // make sure file is loaded
        // reload using current sorting
    }

    // MARK: - Helper Methods -
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
        let dialog = NSOpenPanel();
        // FIXME: Show title
        dialog.title                   = "Open a .csv file";
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
                return
            }

            let path = result.path
            filePath = path
        } else {
            // User cancelled
            return
        }
    }

}

extension SurveyViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        survey?.cellData.count ?? 0
    }
}

extension SurveyViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let rowData = survey?.cellData[row],
              let identifier = tableColumn?.identifier.rawValue else {
            print("couldn't load data for cell view")
            return nil
        }
        guard let index = Int(identifier) else {
            print("Couldn't create index from identifier")
            return nil
        }
        if row == 1 {
            if index == 1 {

            }
        }
        let cellData = rowData[index]
        var cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTextField

        if cell == nil {
            cell = NSTextField(labelWithString: cellData)
            tableColumn?.minWidth = 150
            if cellData.count > 40 {
                tableColumn?.width = 300
            }
            cell!.identifier = tableColumn!.identifier // allows this new cell to be reused
        }
        return cell
    }

}

// MARK: - Toolbar Identifiers -
// Toolbar button identifiers
extension NSToolbarItem.Identifier {
    static let addToolbarButton = NSToolbarItem.Identifier("addToolbarButton")
    static let sortToolbarButton = NSToolbarItem.Identifier("sortToolbarButton")
    static let refreshToolbarButton = NSToolbarItem.Identifier("refreshToolbarButton")
}
