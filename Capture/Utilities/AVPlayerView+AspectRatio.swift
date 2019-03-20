import AVKit

extension AVPlayerView {
    var naturalSize: CGSize {
        let item = player?.currentItem
        let tracks = item?.asset.tracks(withMediaType: .video)
        return tracks?.first?.naturalSize ?? .zero
    }
}
