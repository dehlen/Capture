import AppKit

class ContainerViewController: NSViewController {
    var videoUrl: URL?

    @IBOutlet private weak var containerView: NSView!
    private var currentViewController: NSViewController?
    private var loadingViewController: NSViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Bundle.main.displayName
        view.window?.title = Bundle.main.displayName ?? "Capture"
        setupFirstPage()
        addLoadingIndicator()
    }

    private func setupFirstPage() {
        guard let videoUrl = videoUrl else { return }
        replacePage(with: VideoPlayerViewController.create(with: videoUrl, delegate: self))
    }

    private func replacePage(with currentViewController: NSViewController) {
        if self.currentViewController != nil {
            remove(self.currentViewController!)
        }

        self.currentViewController = currentViewController
        embed(self.currentViewController!, container: containerView)
    }

    private func addLoadingIndicator() {
        loadingViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "LoadingViewController") as? NSViewController
        loadingViewController?.view.wantsLayer = true
        loadingViewController?.view.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.5).cgColor
        embed(loadingViewController!, container: containerView)
        loadingViewController?.view.isHidden = true
    }
}

extension ContainerViewController: ContainerViewControllerDelegate {
    func requestLoadingIndicator() {
       loadingViewController?.view.isHidden = false
    }

    func dismissLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingViewController?.view.isHidden = true
        }
    }

    func requestReplace(new: NSViewController) {
        replacePage(with: new)
    }
}

protocol ContainerViewControllerDelegate: class {
    func requestLoadingIndicator()
    func dismissLoadingIndicator()
    func requestReplace(new: NSViewController)
}
