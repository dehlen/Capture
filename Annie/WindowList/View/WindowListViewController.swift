import AppKit

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
        collectionView.register(NSNib(nibNamed: "CollectionViewItem", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"))
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createGridLayout()
        collectionView.delegate = self
        refresh()
    }

    private func setupObserver() {
        Current.notificationCenter.addObserver(self, selector: #selector(stopRecording), name: .shouldStopRecording, object: nil)
    }

    @objc func stopRecording() {
        guard let currentRecorder = currentRecorder else { return }
        cutoutWindow?.orderOut(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        currentRecorder.stop()
        selectedWindow = nil
        collectionView.deselectAll(nil)
        performSegue(withIdentifier: WindowListViewController.showContainer, sender: nil)
    }

    private func startRecording() {
        guard let selectedWindow = self.selectedWindow, let id = selectedWindow.id else { return }
        do {
            let fullScreenBounds = CGDisplayBounds(selectedWindow.directDisplayID)
            cutoutWindow = CutoutWindow.create(with: fullScreenBounds, cutout: selectedWindow.frame)
            cutoutWindow?.makeKeyAndOrderFront(nil)
            let videoOutputUrl = DirectoryHandler.videoDestination
            currentVideoOutputUrl = videoOutputUrl
            currentRecorder = try recordScreen(destination: videoOutputUrl, displayId: selectedWindow.directDisplayID, cropRect: selectedWindow.frame, audioDevice: nil)
            WindowInfoManager.switchToApp(withWindowId: id)
            currentRecorder?.start()
        } catch let error {
            print(error)
        }
    }

    private func refresh() {
        windowListViewModel.reloadWindows()
        dataSource = .make(for: windowListViewModel.windows)
        collectionView.dataSource = dataSource
    }

    @IBAction func refreshWindowList(_ sender: Any) {
       refresh()
    }

    @IBAction func toggleRecording(_ sender: Any) {
        guard let _ = self.selectedWindow else {
            presentError(NSError.create(from: UserInterfaceError.selectWindow))
            return
        }
        recordingButton.isRecording.toggle()
        if recordingButton.isRecording {
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

