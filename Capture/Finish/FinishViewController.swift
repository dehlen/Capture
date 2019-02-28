import AppKit
import os

enum FinishState {
    case success(_ gifOutputUrl: URL?)
    case failure(_ message: String)
}

class FinishViewController: NSViewController {
    internal var actionNameObservers: [ActionNameObserver] = []

    private var state: FinishState = .failure("genericError".localized)
    @IBOutlet private weak var revealInFinderButton: NSButton!
    @IBOutlet private weak var messageLabel: NSTextField!
    @IBOutlet private weak var imageView: NSImageView!

    static func create(state: FinishState) -> FinishViewController {
        let viewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "FinishViewController") as! FinishViewController
        viewController.state = state
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        switch state {
        case .failure(let message):
            revealInFinderButton.isHidden = true
            messageLabel.stringValue = message
            imageView.image = NSImage(imageLiteralResourceName: "failure")
        case .success(let url):
            revealInFinderButton.isHidden = false
            messageLabel.stringValue = String(format: "successMessage".localized, url?.path ?? "")
            imageView.image = NSImage(imageLiteralResourceName: "success")
        }
    }

    @IBAction func revealInFinder(_ sender: Any) {
        os_log(.info, log: .exportContainer, "Reveal in Finder triggered")

        switch state {
        case .success(let url):
            guard let url = url else { return }
            _ = NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
        case .failure:
            os_log(.info, log: .exportContainer, "Reveal in Finder could not find specified file")
            return
        }
    }
}

extension FinishViewController: ContainerPageable {
    var actionName: String {
        return "Done".localized
    }

    func triggerAction(sender: NSButton, then handler: @escaping (Result<NextContainer>) -> Void) {
        handler(.success(.dismiss))
    }
}
