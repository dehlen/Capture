import AVKit
import os

extension AVPlayerItem {
    typealias URLHandler = ((Result<URL>) -> Void)

    func export(to destination: URL, then handler: @escaping URLHandler) {
        let preset: String = Current.defaults[.movieQuality] ?? AVAssetExportPresetAppleM4V480pSD
        let exportSession = AVAssetExportSession(asset: asset, presetName: preset)!
        exportSession.outputFileType = AVFileType.m4v
        exportSession.outputURL = destination

        let startTime = reversePlaybackEndTime
        let endTime = forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        exportSession.timeRange = timeRange

        exportSession.exportAsynchronously {
            os_log(.info, log: .videoPlayer, "Export Status changed %{public}i", exportSession.status.rawValue)

            switch exportSession.status {
            case .completed:
                handler(.success(destination))
            case .cancelled, .failed, .unknown:
                if let error = exportSession.error as NSError? {
                    os_log(.error, log: .videoPlayer, "Export Status failed %{public}@",
                           error.localizedRecoverySuggestion ?? error.localizedDescription)
                    handler(.failure(VideoPlayerError.exportFailed(reason: error.localizedRecoverySuggestion ?? error.localizedDescription)))
                } else {
                    handler(.failure(VideoPlayerError.exportFailed(reason: "unknown".localized)))
                }
            default: ()
            }
        }
    }
}
