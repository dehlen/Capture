import AppKit

class BitBucketIntegrationViewController: NSViewController {
    var gifOutputUrl: URL?
    private var allOpenPullRequests: [PullRequest] = []
    internal var actionNameObservers: [ActionNameObserver] = []
    @IBOutlet private weak var tableView: DeselectableTableView!
    
    static func create(with gifOutputUrl: URL?) -> BitBucketIntegrationViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "BitBucketIntegrationViewController") as! BitBucketIntegrationViewController
        viewController.gifOutputUrl = gifOutputUrl
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let apiEndpoint: String = UserDefaults.standard[.bitBucketApiEndpoint], !apiEndpoint.isEmpty else { return }
        guard let token: String = UserDefaults.standard[.bitBucketToken], !token.isEmpty else { return }
        let config = TokenConfiguration(apiEndpoint: apiEndpoint, accessToken: token)
        loadPullRequests(config: config)
    }


    func loadPullRequests(config: TokenConfiguration, nextParams: [String: String] = ["state": "OPEN"]) {
        allOpenPullRequests.removeAll()

        _ = BitBucketIntegration(config).pullRequests(nextParameters: nextParams) { result in
            switch result {
            case .success(let paginatedResponse):
                self.allOpenPullRequests.append(contentsOf: paginatedResponse.values.filter { $0.open })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if let nextPageStart = paginatedResponse.nextPageStart {
                    self.loadPullRequests(config: config, nextParams: ["start": "\(nextPageStart)", "state": "OPEN"])
                } else {
                    print("Did finish loading pull requests:")
                    print(self.allOpenPullRequests)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension BitBucketIntegrationViewController: NSTableViewDataSource, NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let PullRequestNumberCell = NSUserInterfaceItemIdentifier("PullRequestNumberCellView")
        static let PullRequestTitleCell = NSUserInterfaceItemIdentifier("PullRequestTitleCellView")
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = allOpenPullRequests[row]
        var text: String = ""
        var cellIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("")

        if tableColumn == tableView.tableColumns[0] {
            text = "\(item.id)"
            cellIdentifier = CellIdentifiers.PullRequestNumberCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.title
            cellIdentifier = CellIdentifiers.PullRequestTitleCell
        } else {
            return nil
        }

        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }

        return nil
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return allOpenPullRequests.count
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow != -1 {
            actionNameDidChange(newValue: "Upload".localized)
        } else {
            actionNameDidChange(newValue: "Continue".localized)
        }
    }

    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        let point = tableView.convert(event.locationInWindow, from: nil)
        let rowIndex = tableView.row(at: point)

        if rowIndex < 0 {
            tableView.deselectAll(nil)
        }
    }
}

extension BitBucketIntegrationViewController: ContainerPageable {
    var actionName: String {
        return "Continue".localized
    }

    func triggerAction(sender: NSButton, then handler: @escaping (Result<NextContainer>) -> Void) {
        #warning("implement")
        handler(.success(.finishPage))
    }
}
