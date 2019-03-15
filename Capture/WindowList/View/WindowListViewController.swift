import AppKit

extension NSNotification.Name {
    static let shouldStopRecording = NSNotification.Name("on-should-stop-recording")
    static let shouldStartRecording = NSNotification.Name("on-should-start-recording")
    static let shouldStopSelection = NSNotification.Name("on-should-stop-selection")
}

class WindowListViewController: NSViewController {
    static let showContainer = "showContainer"

    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var recordingButton: RecordingButton!
    @IBOutlet private weak var optionsButton: NSButton!

    private var windowListViewModel = WindowListViewModel()
    private var selectedWindow: WindowInfo?
    private var currentRecorder: Recorder?
    private var currentVideoOutputUrl: URL?
    private var cutoutWindow: CutoutWindow?
    private var timer: Timer?
    private var statusItem: NSStatusItem?

    private var dataSource = CollectionViewDataSource<WindowInfo>.make(for: []) {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupObserver()
    }

    private func setupCollectionView() {
        collectionView.register(NSNib(nibNamed: "CollectionViewItem", bundle: nil),
                                forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"))
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createGridLayout()
        collectionView.delegate = self
        refresh()
    }

    private func setupObserver() {
        Current.notificationCenter.addObserver(self, selector: #selector(stopRecording), name: .shouldStopRecording, object: nil)
        Current.notificationCenter.addObserver(self, selector: #selector(recordVideo), name: .shouldStartRecording, object: nil)
        Current.notificationCenter.addObserver(self, selector: #selector(stopSelection), name: .shouldStopSelection, object: nil)
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.refresh()
        }
    }

    private func updateSelectedWindow() {
        if let updatedWindow = WindowInfoManager.updateWindow(windowInfo: self.selectedWindow) {
            self.selectedWindow = updatedWindow
        }
    }

    @objc private func stopRecording() {
        stopSelection()
        performSegue(withIdentifier: WindowListViewController.showContainer, sender: nil)
    }

    @objc private func stopSelection() {
        cutoutWindow?.orderOut(nil)
        view.window?.makeKeyAndOrderFront(NSApp)
        currentRecorder?.stop()
        selectedWindow = nil
        collectionView.deselectAll(nil)
    }

    private func startRecording() {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = NSDictionary(dictionary: [promptFlag: true])
        AXIsProcessTrustedWithOptions(myDict)

        if AXIsProcessTrustedWithOptions(myDict) {
            updateSelectedWindow()
            #warning("make cutout window draggable over display borders - this probably means multiple windows 1 per screen")
            var fullScreenBounds = CGDisplayBounds(CGMainDisplayID())
            var frame = NSRect(x: fullScreenBounds.width / 2 - 250, y: fullScreenBounds.height / 2 - 250, width: 500, height: 500)

            if let selectedWindow = self.selectedWindow, let selectedWindowId = selectedWindow.id {
                frame = selectedWindow.frame
                fullScreenBounds = CGDisplayBounds(selectedWindow.directDisplayID)
                WindowInfoManager.switchToApp(withWindowId: selectedWindowId)
            }
            view.window?.orderOut(NSApp)
            cutoutWindow = CutoutWindow(contentRect: fullScreenBounds, styleMask: .borderless, backing: .buffered, defer: true, cutout: frame)
            cutoutWindow?.makeKeyAndOrderFront(nil)

            addStatusBarItem()
        }
    }

    private func addStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let statusItem = statusItem else { return }
        statusItem.button?.image = NSImage(imageLiteralResourceName: "stopRecording")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusBarItemClicked)
    }

    @objc private func statusBarItemClicked() {
        guard let statusItem = statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        stopRecording()
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

    private func refresh() {
        let selectionIndexPaths = collectionView.selectionIndexPaths
        windowListViewModel.reloadWindows()
        dataSource = .make(for: windowListViewModel.windows)
        collectionView.dataSource = dataSource
        collectionView.selectItems(at: selectionIndexPaths, scrollPosition: .nearestHorizontalEdge)
    }

    @IBAction func toggleRecording(_ sender: Any) {
        guard let currentRecorder = currentRecorder else {
            startRecording()
            return
        }

        if !currentRecorder.session.isRunning {
            startRecording()
        } else {
            stopRecording()
        }
    }

    @IBAction func showOptions(_ sender: Any) {
        optionsButton.state = .on
        performSegue(withIdentifier: "showOptionsPopover", sender: nil)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let videoUrl = self.currentVideoOutputUrl else { return }
        if segue.identifier == WindowListViewController.showContainer {
            guard let containerViewController = segue.destinationController as? ContainerViewController else { return }
            containerViewController.videoUrl = videoUrl
        }
    }
}

extension WindowListViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let item = indexPaths.first?.item {
            selectedWindow = windowListViewModel.window(at: item)
        }
    }
}
