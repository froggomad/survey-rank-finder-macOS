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
    /// Is the CSV being sorted using the 80/20 rule?
    var sorted: Bool = false
    /// Have the toolbar buttons been setup?
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

    // MARK: - Toolbar Setup -
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

    // MARK: - CSV Handling -
    private func displayCSV() {
        print(filePath)
        // create CSV object
        // parse
        // add rows to datasource
        // refresh tableview
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

// MARK: - Toolbar Identifiers -
// Toolbar button identifiers
extension NSToolbarItem.Identifier {
    static let addToolbarButton = NSToolbarItem.Identifier("addToolbarButton")
    static let sortToolbarButton = NSToolbarItem.Identifier("sortToolbarButton")
    static let refreshToolbarButton = NSToolbarItem.Identifier("refreshToolbarButton")
}
