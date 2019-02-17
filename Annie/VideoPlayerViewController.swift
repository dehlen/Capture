import AppKit
import AVKit

class VideoPlayerViewController: NSViewController {
    typealias Handler = ((Result<Void, NSError>) -> Void)
    @IBOutlet private weak var playerView: AVPlayerView!
    var videoUrl: URL?

    private var didCallBeginTrimming: Bool = false
    private var beginTrimmingObserver: NSKeyValueObservation?

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

    @IBAction func convertToGif(_ sender: NSButton) {
        sender.isEnabled = false
        exportVideo() { result in
            DispatchQueue.main.async {
                sender.isEnabled = true
                switch result {
                case .success:
                    self.convertVideoToGif()
                case .failure(let error):
                    print("Error exporting trimmed video: \(error)")
                }
            }
        }
    }

    private func trimmedOutputUrl() -> URL? {
        guard let videoOutputUrl = videoUrl else { return nil }
        let fileName = videoOutputUrl.path.fileName
        return videoOutputUrl.deletingPathExtension().deletingLastPathComponent().appendingPathComponent(fileName + "-trimmed".mov)
    }

    private func convertVideoToGif() {
        guard let trimmedVideoOutputUrl = trimmedOutputUrl() else { return }
        guard let exportFolderUrl = DirectoryHandler.exportFolder else { return }

        let gifOutputUrl = exportFolderUrl.appendingPathComponent(trimmedVideoOutputUrl.path.fileName.gif)
        ConvertGif.convert(at: trimmedVideoOutputUrl, to: gifOutputUrl) { (result) in
            switch result {
            case .success:
                try? NotificationHandler.send(gifUrl: gifOutputUrl)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.dismiss(self)
                }
            case .failure(let error):
                print(error)
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
        let timeRange = CMTimeRangeFromTimeToTime(startTime, endTime)
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
