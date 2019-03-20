import AppKit

class WindowListViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var recordingButton: RecordingButton!
    @IBOutlet private weak var optionsButton: NSButton!

    private var windowListViewModel = WindowListViewModel()
    private var statusBarItemController = StatusBarItemController()
    private var selectedWindow: WindowInfo?
    private var currentRecorder: Recorder?
    private var currentVideoOutputUrl: URL?
    private var cutoutWindow: CutoutWindow?

    private var dataSource = CollectionViewDataSource<WindowInfo>.make(for: []) {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupObserver()
        windowListViewModel.delegate = self
        statusBarItemController.delegate = self
    }

    private func setupCollectionView() {
        collectionView.register(NSNib(nibNamed: "CollectionViewItem", bundle: nil),
                                forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"))
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createGridLayout()
        collectionView.delegate = self
    }

    private func setupObserver() {
        Current.notificationCenter.addObserver(self, selector: #selector(stopRecording), name: .shouldStopRecording, object: nil)
        Current.notificationCenter.addObserver(self, selector: #selector(recordVideo), name: .shouldStartRecording, object: nil)
        Current.notificationCenter.addObserver(self, selector: #selector(stopSelection), name: .shouldStopSelection, object: nil)
    }

    private func updateSelectedWindow() {
        if let updatedWindow = WindowInfoManager.updateWindow(windowInfo: self.selectedWindow) {
            self.selectedWindow = updatedWindow
        }
    }

    private func showCutoutWindow(contentRect: CGRect, cutout: CGRect) {
        view.window?.orderOut(NSApp)
        cutoutWindow = CutoutWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: true, cutout: cutout)
        cutoutWindow?.makeKeyAndOrderFront(nil)
    }

    private func showWindowList() {
        cutoutWindow?.orderOut(nil)
        cutoutWindow = nil
        view.window?.makeKeyAndOrderFront(NSApp)
    }

    private func deselectWindows() {
        selectedWindow = nil
        collectionView.deselectAll(nil)
    }

    private func startSelection() {
        guard hasAccessibilityPermission() else {
            askForAccessibilityPermission()
            return
        }

        updateSelectedWindow()

        var fullScreenBounds = CGDisplayBounds(CGMainDisplayID())
        var frame = fullScreenBounds.centerRect(withSize: 500)
        if let selectedWindow = self.selectedWindow, let selectedWindowId = selectedWindow.id {
            frame = selectedWindow.frame
            fullScreenBounds = CGDisplayBounds(selectedWindow.directDisplayID)
            WindowInfoManager.switchToApp(withWindowId: selectedWindowId)
        }

        showCutoutWindow(contentRect: fullScreenBounds, cutout: frame)
        statusBarItemController.addStopRecordingItem()
    }

    @objc private func stopSelection() {
        statusBarItemController.removeStopRecordingItem()
        showWindowList()
        deselectWindows()
    }

    @objc private func recordVideo() {
        guard let cutoutWindow = self.cutoutWindow else { return }
        let cutoutFrame = cutoutWindow.cutoutFrame
        cutoutWindow.recordingStarted()

        do {
            let videoOutputUrl = DirectoryHandler.videoDestination
            currentVideoOutputUrl = videoOutputUrl
            currentRecorder = try recordScreen(
                destination: videoOutputUrl,
                displayId: cutoutWindow.directDisplayId,
                cropRect: cutoutFrame,
                audioDevice: nil
            )
            currentRecorder?.start()

        } catch let error {
            print(error)
        }
    }

    @objc private func stopRecording() {
        stopSelection()
        guard let currentRecorder = currentRecorder else {
            return
        }
        currentRecorder.stop()
        self.currentRecorder = nil
        showContainer()
    }

    private func showContainer() {
        guard let videoUrl = self.currentVideoOutputUrl else { return }
        let containerViewController = ContainerViewController.create(videoUrl: videoUrl)
        presentAsModalWindow(containerViewController)
    }
}

// MARK: - WindowListViewControllerDelegate
extension WindowListViewController: WindowListViewControllerDelegate {
    func didRefreshWindowList() {
        let selectionIndexPaths = collectionView.selectionIndexPaths
        dataSource = .make(for: windowListViewModel.windows)
        collectionView.dataSource = dataSource
        collectionView.selectItems(at: selectionIndexPaths, scrollPosition: .nearestHorizontalEdge)
    }
}

// MARK: - StatusBar
extension WindowListViewController: StatusBarItemControllerDelegate {
    func didClickStatusBarItem() {
        statusBarItemController.removeStopRecordingItem()
        stopRecording()
    }
}

// MARK: - Actions
extension WindowListViewController {
    @IBAction private func recordingButtonPressed(_ sender: Any) {
        let isRunning = currentRecorder?.session.isRunning ?? false

        if !isRunning {
            startSelection()
        }
    }

    @IBAction private func showOptions(_ sender: Any) {
        optionsButton.state = .on
        performSegue(withIdentifier: "showOptionsPopover", sender: nil)
    }
}

extension WindowListViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let item = indexPaths.first?.item {
            selectedWindow = windowListViewModel.window(at: item)
        }
    }

    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        deselectWindows()
    }
}
