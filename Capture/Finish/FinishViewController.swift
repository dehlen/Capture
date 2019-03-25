import AppKit
import os

class FinishViewController: NSViewController {
    private var state: FinishState = .failure("genericError".localized)

    @IBOutlet private weak var revealInFinderButton: NSButton!
    @IBOutlet private weak var messageLabel: NSTextField!
    @IBOutlet private weak var imageView: NSImageView!

    static func create(state: FinishState) -> FinishViewController {
        let viewController = FinishViewController(nibName: nil, bundle: nil)
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

    @IBAction private func revealInFinder(_ sender: Any) {
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
