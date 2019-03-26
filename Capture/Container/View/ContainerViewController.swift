import AppKit

class ContainerViewController: NSViewController {
    var videoUrl: URL?

    private var currentViewController: NSViewController?
    private var loadingViewController: LoadingViewController?

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Bundle.main.displayName
        view.window?.title = Bundle.main.displayName ?? "Capture"

        setupFirstPage()
        addLoadingIndicator()
    }

    static func create(videoUrl: URL) -> ContainerViewController {
        let containerViewController = ContainerViewController()
        containerViewController.videoUrl = videoUrl
        return containerViewController
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
        embed(self.currentViewController!, container: view)
    }

    private func addLoadingIndicator() {
        loadingViewController = LoadingViewController.create()
        loadingViewController?.view.wantsLayer = true
        loadingViewController?.view.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.5).cgColor
        embed(loadingViewController!, container: view)
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
        dismissLoadingIndicator()
        replacePage(with: new)
    }

    func exportProgressDidChange(progress: Double) {
        loadingViewController?.progress = progress
    }
}
