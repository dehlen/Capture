import AppKit
import os

class BitBucketIntegrationViewController: NSViewController {
    typealias Handler = ((Result<Void>) -> Void)
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

    private var config: TokenConfiguration? {
        guard let apiEndpoint: String = Current.defaults[.bitBucketApiEndpoint], !apiEndpoint.isEmpty else { return nil }
        guard let token: String = Current.defaults[.bitBucketToken], !token.isEmpty else { return nil }
        let config = TokenConfiguration(apiEndpoint: apiEndpoint, accessToken: token)
        return config
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, log: .bitBucket, "BitBucket Screen loaded")

        guard let config = config else { return }
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
                }
            case .failure(let error):
                os_log(.default, log: .bitBucket, "Requesting open PRs from BitBucket failed, %{public}@", error.localizedDescription)
            }
        }
    }

    func addAttachment(config: TokenConfiguration, file: URL, pullRequest: PullRequest, then handler: @escaping Handler) {
        _ = BitBucketIntegration(config).addAttachment(attachment: file, to: pullRequest, completion: { result in
            switch result {
            case .success(let attachment):
                self.comment(config: config, on: pullRequest, with: attachment, then: handler)
            case .failure(let error):
                os_log(.default, log: .bitBucket, "Adding an attachment to BitBucket failed, %{public}@", error.localizedDescription)
                handler(.failure(error))
            }
        })
    }

    func comment(config: TokenConfiguration, on pullRequest: PullRequest, with attachment: Attachment, then handler: @escaping Handler) {
        _ = BitBucketIntegration(config).comment(on: pullRequest, with: attachment, completion: { result in
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                os_log(.default, log: .bitBucket, "Adding a comment to BitBucket failed, %{public}@", error.localizedDescription)
                handler(.failure(error))
            }
        })
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
        guard let fileUrl = gifOutputUrl else {
            os_log(.default, log: .bitBucket, "Exported GIF could not be found")
            handler(.failure(NSError.create(from: BitBucketIntegrationError.missingFile)))
            return
        }

        guard let config = config else {
            os_log(.default, log: .bitBucket, "No authorized BitBucket account")
            handler(.failure(NSError.create(from: BitBucketIntegrationError.notAuthorized)))
            return
        }

        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 && selectedRow < allOpenPullRequests.count {
            let selectedPullRequest = allOpenPullRequests[tableView.selectedRow]
            DispatchQueue.main.async {
                sender.isEnabled = false
            }
            addAttachment(config: config, file: fileUrl, pullRequest: selectedPullRequest, then: { result in
                DispatchQueue.main.async {
                    sender.isEnabled = true
                }
                switch result {
                case .success:
                    handler(.success(NextContainer.finishPage(fileUrl)))
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        } else {
            handler(.failure(NSError.create(from: BitBucketIntegrationError.uploadFailed)))
        }
    }
}
