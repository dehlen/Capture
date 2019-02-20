import AppKit

class ContainerViewController: NSViewController {
    var videoUrl: URL?
    var gifOutputUrl: URL?

    @IBOutlet private weak var actionButton: NSButton!
    @IBOutlet private weak var containerView: NSView!
    private var currentPageable: ContainerPageable?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Annie"
        view.window?.title = "Annie"
        setupFirstPage()
    }

    private func setupFirstPage() {
        guard let videoUrl = videoUrl else { return }
        replacePage(with: VideoPlayerViewController.create(with: videoUrl))
    }

    private func replacePage(with pageable: ContainerPageable) {
        DispatchQueue.main.async {
            if self.currentPageable != nil {
                self.remove(self.currentPageable!.viewController)
            }
            self.currentPageable = pageable
            self.currentPageable?.register(observer: self)

            self.actionButton.title = pageable.actionName
            self.actionButton.target = self
            self.actionButton.action = #selector(self.triggerCurrentPageableAction)

            self.embed(self.currentPageable!.viewController, container: self.containerView)
        }
    }

    @objc func triggerCurrentPageableAction() {
        currentPageable?.triggerAction(sender: actionButton, then: { (result) in
            switch result {
            case .success(let nextContainer):
                switch nextContainer {
                case .bitBucketIntegration(let gifOutputUrl):
                    self.gifOutputUrl = gifOutputUrl
                    self.replacePage(with: BitBucketIntegrationViewController.create(with: gifOutputUrl))
                case .finishPage(let gifOutputUrl):
                    self.gifOutputUrl = gifOutputUrl
                    self.replacePage(with:
                        FinishViewController.create(state: .success(self.gifOutputUrl)))
                case .dismiss:
                    self.view.window?.performClose(nil)
                }
            case .failure(let error):
                self.replacePage(with: FinishViewController.create(state: .failure(ErrorMessageProvider.string(for: error))))
            }
        })
    }
}

extension ContainerViewController: ActionNameObserver {
    func didChangeActionName(newValue: String) {
        DispatchQueue.main.async {
            self.actionButton.title = newValue
        }
    }
}
