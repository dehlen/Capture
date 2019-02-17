import AppKit

class WindowListViewController: NSViewController {
    static let videoPlayerSegue = NSStoryboard.SegueIdentifier("showVideoPlayer")

    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var recordingButton: RecordingButton!

    private var windowListViewModel = WindowListViewModel()
    private var selectedWindow: WindowInfo?
    private var currentRecorder: Recorder?
    private var currentVideoOutputUrl: URL?
    private var dataSource = CollectionViewDataSource<WindowInfo>.make(for: []) {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.register(NSNib(nibNamed: NSNib.Name(rawValue: "CollectionViewItem"), bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"))
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createGridLayout()
        collectionView.delegate = self
        refresh()
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
            guard let selectedWindow = self.selectedWindow, let displayId = selectedWindow.directDisplayID, let id = selectedWindow.id else { return }
            do {
                let videoOutputUrl = DirectoryHandler.videoDestination
                currentVideoOutputUrl = videoOutputUrl
                currentRecorder = try recordScreen(destination: videoOutputUrl, displayId: displayId, cropRect: selectedWindow.frame, audioDevice: nil)
                WindowInfoManager.switchToApp(withWindowId: id)
                currentRecorder?.start()
            } catch let error {
                print(error)
            }

        } else {
            currentRecorder?.stop()
            selectedWindow = nil
            collectionView.deselectAll(nil)
            performSegue(withIdentifier: WindowListViewController.videoPlayerSegue, sender: nil)
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let videoUrl = self.currentVideoOutputUrl else { return }

        if segue.identifier == WindowListViewController.videoPlayerSegue {
            guard let videoPlayerViewController = segue.destinationController as? VideoPlayerViewController else { return }
            videoPlayerViewController.videoUrl = videoUrl
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

