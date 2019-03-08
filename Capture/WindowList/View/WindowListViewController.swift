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
    private var timer: Timer?
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
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.refresh()
        }
    }

    @objc func stopRecording() {
        recordingButton.isRecording = false
        guard let currentRecorder = currentRecorder else { return }
        cutoutWindow?.orderOut(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        currentRecorder.stop()
        selectedWindow = nil
        collectionView.deselectAll(nil)
        performSegue(withIdentifier: WindowListViewController.showContainer, sender: nil)
    }

    private func startRecording() {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = NSDictionary(dictionary: [promptFlag: true])
        AXIsProcessTrustedWithOptions(myDict)

        if AXIsProcessTrustedWithOptions(myDict) {
            if let updatedWindow = WindowInfoManager.updateWindow(windowInfo: self.selectedWindow) {
                self.selectedWindow = updatedWindow
            }

            guard let selectedWindow = self.selectedWindow, let id = selectedWindow.id else { return }
            do {
                recordingButton.isRecording = true
                let videoOutputUrl = DirectoryHandler.videoDestination
                currentVideoOutputUrl = videoOutputUrl
                currentRecorder = try recordScreen(
                    destination: videoOutputUrl,
                    displayId: selectedWindow.directDisplayID,
                    cropRect: selectedWindow.frame,
                    audioDevice: nil
                )
                WindowInfoManager.switchToApp(withWindowId: id)

                let fullScreenBounds = CGDisplayBounds(selectedWindow.directDisplayID)
                cutoutWindow = CutoutWindow.create(with: fullScreenBounds, cutout: selectedWindow.frame)
                cutoutWindow?.makeKeyAndOrderFront(nil)

                currentRecorder?.start()
            } catch let error {
                print(error)
            }
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
        guard selectedWindow != nil else {
            presentError(NSError.create(from: UserInterfaceError.selectWindow))
            return
        }
        if !recordingButton.isRecording {
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
