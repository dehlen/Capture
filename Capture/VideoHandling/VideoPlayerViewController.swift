import AppKit
import AVKit
import os

#warning("refactor")
class VideoPlayerViewController: NSViewController {
    typealias URLHandler = ((Result<URL>) -> Void)
    typealias ProgressHandler = ((Double) -> Void)

    @IBOutlet private weak var playerView: AVPlayerView!
    @IBOutlet private weak var heightTextField: NSTextField!
    @IBOutlet private weak var widthTextField: NSTextField!
    @IBOutlet private weak var fpsSegmentedControl: NSSegmentedControl!

    var videoUrl: URL?
    weak var delegate: ContainerViewControllerDelegate?

    private var didCallBeginTrimming: Bool = false
    private var beginTrimmingObserver: NSKeyValueObservation?
    private var naturalVideoSize: CGSize = .zero

    @objc dynamic var selectedFramerateIndex: Int {
        get {
            return Current.defaults[.selectedFramerateIndex] ?? 1
        }
        set {
            Current.defaults[.selectedFramerateIndex] = newValue
        }
    }

    static func create(with videoUrl: URL?, delegate: ContainerViewControllerDelegate?) -> VideoPlayerViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: "VideoPlayerViewController") as? VideoPlayerViewController else {
            fatalError("Could not instantiate VideoPlayerViewController")
        }

        viewController.videoUrl = videoUrl
        viewController.delegate = delegate
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, log: .videoPlayer, "VideoPlayer loaded")

        guard let videoUrl = self.videoUrl else {
            os_log(.default, log: .videoPlayer, "Video not found")
            return
        }

        loadVideo(at: videoUrl)
        calculateNaturalVideoSize()
        setupUI()
    }

    private func loadVideo(at videoUrl: URL) {
        let player = AVPlayer(url: videoUrl)
        playerView.player = player
        beginTrimmingObserver = playerView.observe(\AVPlayerView.canBeginTrimming, options: .new) { playerView, change in
            if change.newValue == true {
                if !self.didCallBeginTrimming {
                    self.didCallBeginTrimming = true
                    self.playerView.beginTrimming(completionHandler: nil)
                }
            }
        }
    }

    private func calculateNaturalVideoSize() {
        let item = playerView.player?.currentItem
        let tracks = item?.asset.tracks(withMediaType: .video)
        naturalVideoSize = tracks?.first?.naturalSize ?? .zero
    }

    private func setupUI() {
        heightTextField.stringValue = String(format: "%.0f", naturalVideoSize.height)
        widthTextField.stringValue = String(format: "%.0f", naturalVideoSize.width)
        heightTextField.delegate = self
        widthTextField.delegate = self
    }

    private func trimmedOutputUrl() -> URL? {
        guard let videoOutputUrl = videoUrl else { return nil }
        let fileName = videoOutputUrl.path.fileName
        return videoOutputUrl.deletingPathExtension().deletingLastPathComponent().appendingPathComponent(fileName + "-trimmed".mov)
    }

    private func convertVideoToGif(progressHandler: @escaping ProgressHandler, then handler: @escaping URLHandler) {
        guard let trimmedVideoOutputUrl = trimmedOutputUrl() else { return }
        guard let exportFolderUrl = DirectoryHandler.exportFolder else { return }
        guard let asset = playerView.player?.currentItem?.asset else {
            handler(.failure(GifConversionError.missingAsset))
            return
        }

        DispatchQueue.main.async {
            let gifOutputUrl = exportFolderUrl.appendingPathComponent(trimmedVideoOutputUrl.path.fileName.gif)
            let duration = Float(asset.duration.value) / Float(asset.duration.timescale)
            let frameRate = Int(self.fpsSegmentedControl.label(forSegment: self.fpsSegmentedControl.selectedSegment) ?? "30") ?? 30
            let width = Int(self.widthTextField.stringValue) ?? 0
            let height = Int(self.heightTextField.stringValue) ?? 480
            ConvertGif.convert(at: trimmedVideoOutputUrl,
                               to: gifOutputUrl,
                               frameRate: frameRate,
                               width: width,
                               maximumHeight: height,
                               duration: duration,
                               progressHandler: progressHandler) { (result) in
                switch result {
                case .success:
                    handler(.success(gifOutputUrl))
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }

    private func exportVideo(then handler: @escaping URLHandler) {
        guard let playerItem = playerView.player?.currentItem else {
            os_log(.info, log: .videoPlayer, "VideoPlayer current item is nil")
            handler(.failure(VideoPlayerError.noCurrentItem))
            return
        }
        guard let outputUrl = trimmedOutputUrl() else {
            os_log(.info, log: .videoPlayer, "Video file could not be found")
            handler(.failure(VideoPlayerError.missingFile))
            return
        }

        let preset: String = Current.defaults[.movieQuality] ?? AVAssetExportPresetAppleM4V480pSD
        let exportSession = AVAssetExportSession(asset: playerItem.asset, presetName: preset)!
        exportSession.outputFileType = AVFileType.m4v
        exportSession.outputURL = outputUrl

        let startTime = playerItem.reversePlaybackEndTime
        let endTime = playerItem.forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        exportSession.timeRange = timeRange

        exportSession.exportAsynchronously {
            os_log(.info, log: .videoPlayer, "Export Status changed %{public}i", exportSession.status.rawValue)
            switch exportSession.status {
            case .completed:
                handler(.success(outputUrl))
            case .cancelled, .failed, .unknown:
                handler(.failure(VideoPlayerError.exportFailed))
            default: ()
            }
        }
    }
}

extension VideoPlayerViewController {
    /// Triggered via First Responder Chain
    @IBAction func toggleTrimming(_ sender: Any) {
        if playerView.canBeginTrimming {
            playerView.beginTrimming(completionHandler: nil)
        }
    }

    @IBAction func export(_ sender: NSButton) {
        sender.isEnabled = false
        delegate?.requestLoadingIndicator()
        exportVideo { result in
            switch result {
            case .success(let videoUrl):
                if Current.defaults[.saveVideo] == true {
                    DirectoryHandler.copy(from: videoUrl)
                }
                self.convertVideoToGif(progressHandler: { (progress) in
                    self.delegate?.exportProgressDidChange(progress: progress)
                }, then: { convertResult in
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                        switch convertResult {
                        case .success(let gifOutputUrl):
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.delegate?.dismissLoadingIndicator()
                                self.delegate?.requestReplace(new: FinishViewController.create(state: .success(gifOutputUrl)))
                            }
                        case .failure(let error):
                            let errorMessage = ErrorMessageProvider.string(for: NSError.create(from: error))
                            self.delegate?.requestReplace(new: FinishViewController.create(state: .failure(errorMessage)))
                        }
                    }
                })
            case .failure(let error):
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    let errorMessage = ErrorMessageProvider.string(for: error)
                    self.delegate?.requestReplace(new: FinishViewController.create(state: .failure(errorMessage)))
                }
            }
        }
    }
}

extension VideoPlayerViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField == heightTextField {
            widthTextField.stringValue = "\(aspectRatioWidth(height: heightTextField.stringValue))"
        } else if textField == widthTextField {
            heightTextField.stringValue = "\(aspectRatioHeight(width: widthTextField.stringValue))"
        }
    }

    private func aspectRatioWidth(height: String) -> Int {
        let item = playerView.player?.currentItem
        let tracks = item?.asset.tracks(withMediaType: .video)
        let naturalSize = tracks?.first?.naturalSize ?? .zero
        let aspectRatio: Double = Double(naturalSize.width / naturalSize.height)
        let heightValue = Double(height) ?? 0

        return Int(heightValue * aspectRatio)
    }

    private func aspectRatioHeight(width: String) -> Int {
        let item = playerView.player?.currentItem
        let tracks = item?.asset.tracks(withMediaType: .video)
        let naturalSize = tracks?.first?.naturalSize ?? .zero
        let aspectRatio: Double = Double(naturalSize.height / naturalSize.width)
        let widthValue = Double(width) ?? 0

        return Int(widthValue * aspectRatio)
    }
}
