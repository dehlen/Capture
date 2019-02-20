import AppKit
import AVKit

class VideoPlayerViewController: NSViewController {
    typealias Handler = ((Result<Void>) -> Void)
    typealias URLHandler = ((Result<URL>) -> Void)

    @IBOutlet private weak var playerView: AVPlayerView!
    var videoUrl: URL?

    internal var actionNameObservers: [ActionNameObserver] = []
    private var didCallBeginTrimming: Bool = false
    private var beginTrimmingObserver: NSKeyValueObservation?

    static func create(with videoUrl: URL?) -> VideoPlayerViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
        viewController.videoUrl = videoUrl
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let videoUrl = self.videoUrl else { return }
        loadVideo(at: videoUrl)
    }

    func loadVideo(at videoUrl: URL) {
        let player = AVPlayer(url: videoUrl)
        playerView.player = player

        beginTrimmingObserver = playerView.observe(\AVPlayerView.canBeginTrimming, options: .new) { playerView, change in
            if !self.didCallBeginTrimming && change.newValue == true {
                self.didCallBeginTrimming = true
                self.playerView.beginTrimming(completionHandler: nil)
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
                print(error)
                handler(.failure(error))
            }
        }
    }

    private func exportVideo(then handler: @escaping Handler) {
        guard let playerItem = playerView.player?.currentItem else { return }
        guard let outputUrl = trimmedOutputUrl() else { return }

        let preset: String = UserDefaults.standard[.movieQuality] ?? AVAssetExportPresetAppleM4V480pSD
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
                handler(.success(()))
            default:
                return handler(.failure(NSError(domain: "com.davidehlen.Annie", code: 1000, userInfo: ["status": exportSession.status.rawValue])))
            }
        }
    }
}

extension VideoPlayerViewController: ContainerPageable {
    var actionName: String {
        return "ConvertToGif".localized
    }

    func triggerAction(sender: NSButton, then handler: @escaping (Result<NextContainer>) -> Void) {
        DispatchQueue.main.async {
            sender.isEnabled = false
        }
        exportVideo() { result in
            switch result {
            case .success:
                self.convertVideoToGif() { convertResult in
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                    }
                    switch convertResult {
                    case .success(let gifOutputUrl):
                        guard let apiEndpoint: String = UserDefaults.standard[.bitBucketApiEndpoint], !apiEndpoint.isEmpty else {
                            handler(.success(.finishPage(gifOutputUrl)))
                            return
                        }
                        guard let token: String = UserDefaults.standard[.bitBucketToken], !token.isEmpty else {
                            handler(.success(.finishPage(gifOutputUrl)))
                            return
                        }

                        handler(.success(.bitBucketIntegration(gifOutputUrl)))
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    handler(.failure(error))
                }
            }
        }
    }
}
