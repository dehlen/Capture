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
    private var cutoutWindows: [CutoutWindow] = []

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
    }

    private func updateSelectedWindow() {
        if let updatedWindow = WindowInfoManager.updateWindow(windowInfo: self.selectedWindow) {
            self.selectedWindow = updatedWindow
        }
    }

    private func showCutoutWindow(cutout: CGRect) {
        view.window?.orderOut(NSApp)
        cutoutWindows.removeAll()
        for screen in NSScreen.screens {
            let fullscreenBounds = CGDisplayBounds(screen.displayID ?? CGMainDisplayID())
            var frame = fullscreenBounds.centerRect(withSize: 500)
            let cutoutWindow = CutoutWindow(contentRect: fullscreenBounds,
                                            styleMask: .borderless,
                                            backing: .buffered,
                                            defer: true,
                                            cropViewDelegate: self)
            if let selectedWindow = selectedWindow {
                if screen.displayID == selectedWindow.directDisplayID {
                    frame = selectedWindow.frame
                    cutoutWindow.makeKeyAndOrderFront(NSApp)
                    cutoutWindow.showCrop(at: frame, initial: true)
                } else {
                    cutoutWindow.orderFront(NSApp)
                }
            } else if screen == NSScreen.main {
                cutoutWindow.makeKeyAndOrderFront(NSApp)
                cutoutWindow.showCrop(at: frame, initial: true)
            } else {
                cutoutWindow.orderFront(NSApp)
            }
            cutoutWindows.append(cutoutWindow)
        }
    }

    private func closeCutoutWindow(_ cutoutWindow: CutoutWindow) {
        let old_isReleasedWhenClosed = cutoutWindow.isReleasedWhenClosed
        cutoutWindow.isReleasedWhenClosed = false
        cutoutWindow.close()
        cutoutWindow.isReleasedWhenClosed = old_isReleasedWhenClosed
    }

    private func showWindowList() {
        for window in cutoutWindows {
            closeCutoutWindow(window)
        }
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

        let fullScreenBounds = CGDisplayBounds(CGMainDisplayID())
        var frame = fullScreenBounds.centerRect(withSize: 500)
        if let selectedWindow = self.selectedWindow, let selectedWindowId = selectedWindow.id {
            frame = selectedWindow.frame
            WindowInfoManager.switchToApp(withWindowId: selectedWindowId)
        }

        showCutoutWindow(cutout: frame)
        statusBarItemController.addStopRecordingItem()
    }

    @objc private func stopSelection() {
        statusBarItemController.removeStopRecordingItem()
        showWindowList()
        deselectWindows()
    }

    @objc private func recordVideo(in cutoutWindow: CutoutWindow) {
        let cutoutFrame = cutoutWindow.cutoutFrame
        cutoutWindows.filter { $0 != cutoutWindow}.forEach { closeCutoutWindow($0) }
        cutoutWindow.recordingStarted()

        do {
            let videoOutputUrl = DirectoryHandler.videoDestination
            currentVideoOutputUrl = videoOutputUrl
            currentRecorder = try recordScreen(
                destination: videoOutputUrl,
                displayId: cutoutWindow.directDisplayId,
                cropRect: cutoutFrame == .zero ? nil : cutoutFrame,
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
        present(VideoOptionViewController.create(), asPopoverRelativeTo: optionsButton.frame, of: view, preferredEdge: .minY, behavior: .transient)
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

extension WindowListViewController: CropViewDelegate {
    func shouldStartRecording(cutoutWindow: CutoutWindow) {
        recordVideo(in: cutoutWindow)
    }

    func didSelectNewCropView(on cutoutWindow: CutoutWindow) {
        cutoutWindows.filter { $0 != cutoutWindow }.forEach { $0.cancel() }
    }

    func shouldCancelSelection() {
        let isRunning = currentRecorder?.session.isRunning ?? false
        if !isRunning {
            stopSelection()
        }
    }
}
