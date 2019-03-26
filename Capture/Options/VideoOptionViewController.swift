import AppKit
import AVFoundation
import os

class VideoOptionViewController: NSViewController {
    @IBOutlet private weak var movieQualityPopUpButton: NSPopUpButton!

    static func create() -> VideoOptionViewController {
        return VideoOptionViewController(nibName: nil, bundle: nil)
    }

    var movieQualityTitle: String {
        let movieQualityString: String = Current.defaults[.movieQuality] ?? "480p"
        switch movieQualityString {
        case AVAssetExportPresetAppleM4V720pHD:
            return "720p"
        case AVAssetExportPresetAppleM4V1080pHD:
            return "1080p"
        default:
            return "480p"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, log: .mainScreen, "Showing options")

        movieQualityPopUpButton.selectItem(withTitle: movieQualityTitle)
    }

    @IBAction private func selectMovieQuality(_ sender: NSPopUpButton) {
        let selectedString = sender.titleOfSelectedItem ?? "480p"
        var selectedMovieQuality: String!

        switch selectedString {
        case "720p":
            selectedMovieQuality = AVAssetExportPresetAppleM4V720pHD
        case "1080p":
            selectedMovieQuality = AVAssetExportPresetAppleM4V1080pHD
        default:
            selectedMovieQuality = AVAssetExportPresetAppleM4V480pSD
        }

        Current.defaults[.movieQuality] = selectedMovieQuality
    }
}
