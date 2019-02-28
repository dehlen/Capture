import AppKit
import AVKit
import os

enum VideoPlayerError: Error {
    case noCurrentItem
    case missingFile
    case exportFailed
}

class VideoPlayerViewController: NSViewController {
    typealias URLHandler = ((Result<URL>) -> Void)

    @IBOutlet private weak var playerView: AVPlayerView!
    @IBOutlet private weak var trimButton: NSButton!
    var videoUrl: URL?
    weak var delegate: ContainerViewControllerDelegate?

    private var didCallBeginTrimming: Bool = false
    private var beginTrimmingObserver: NSKeyValueObservation?

    static func create(with videoUrl: URL?, delegate: ContainerViewControllerDelegate?) -> VideoPlayerViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
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
    }

    func loadVideo(at videoUrl: URL) {
        let player = AVPlayer(url: videoUrl)
        playerView.player = player
        beginTrimmingObserver = playerView.observe(\AVPlayerView.canBeginTrimming, options: .new) { playerView, change in
            if change.newValue == true {
                self.trimButton.contentTintColor = NSColor.labelColor

                if !self.didCallBeginTrimming {
                    self.didCallBeginTrimming = true
                    self.playerView.beginTrimming(completionHandler: nil)
                }
            } else {
                self.trimButton.contentTintColor = NSColor.controlAccentColor
            }
        }
    }
    
    private func trimmedOutputUrl() -> URL? {
        guard let videoOutputUrl = videoUrl else { return nil }
        let fileName = videoOutputUrl.path.fileName
        return videoOutputUrl.deletingPathExtension().deletingLastPathComponent().appendingPathComponent(fileName + "-trimmed".mov)
    }

    private func convertVideoToGif(then handler: @escaping URLHandler) {
        guard let trimmedVideoOutputUrl = trimmedOutputUrl() else { return }
        guard let exportFolderUrl = DirectoryHandler.exportFolder else { return }

        let gifOutputUrl = exportFolderUrl.appendingPathComponent(trimmedVideoOutputUrl.path.fileName.gif)
        ConvertGif.convert(at: trimmedVideoOutputUrl, to: gifOutputUrl) { (result) in
            switch result {
            case .success:
                handler(.success(gifOutputUrl))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    private func exportVideo(then handler: @escaping URLHandler) {
        guard let playerItem = playerView.player?.currentItem else {
            handler(.failure(NSError.create(from: VideoPlayerError.noCurrentItem)))
            os_log(.info, log: .videoPlayer, "VideoPlayer current item is nil")
            return
        }
        guard let outputUrl = trimmedOutputUrl() else {
            os_log(.info, log: .videoPlayer, "Video file could not be found")
            handler(.failure(NSError.create(from: VideoPlayerError.missingFile)))
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
            switch exportSession.status {
            case .completed:
                handler(.success(outputUrl))
            default:
                os_log(.info, log: .videoPlayer, "Export Status changed %{public}i", exportSession.status.rawValue)
                return handler(.failure(NSError.create(from: VideoPlayerError.exportFailed)))
            }
        }
    }
}

extension VideoPlayerViewController {
    @IBAction func toggleTrimming(_ sender: Any) {
        if playerView.canBeginTrimming {
            playerView.beginTrimming(completionHandler: nil)
        }
    }

    @IBAction func export(_ sender: NSButton) {
        sender.isEnabled = false
        delegate?.requestLoadingIndicator()
        exportVideo() { result in
            switch result {
            case .success(let videoUrl):
                if Current.defaults[.saveVideo] == true {
                    DirectoryHandler.copy(from: videoUrl)
                }
                self.convertVideoToGif() { convertResult in
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                        switch convertResult {
                        case .success(let gifOutputUrl):
                            self.delegate?.dismissLoadingIndicator()
                            self.delegate?.requestReplace(new: FinishViewController.create(state: .success(gifOutputUrl)))
                        case .failure(let error):
                            let errorMessage = ErrorMessageProvider.string(for: NSError.create(from: error))
                            self.delegate?.requestReplace(new: FinishViewController.create(state: .failure(errorMessage)))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    let errorMessage = ErrorMessageProvider.string(for: NSError.create(from: error))
                    self.delegate?.requestReplace(new: FinishViewController.create(state: .failure(errorMessage)))
                }
            }
        }
    }
}
