import AppKit
import AVFoundation

class AdvancedPreferencesViewController: PreferencesViewController {
    @IBOutlet private weak var gifFrameRateStepper: NSStepper!
    @IBOutlet private weak var movieQualityPopUpButton: NSPopUpButton!

    @objc dynamic var gifHeight: String {
        get {
            return String(UserDefaults.standard[.gifHeight] ?? "720")
        }
        set {
            if newValue.isNumeric {
                UserDefaults.standard[.gifHeight] = newValue
            }
        }
    }

    @objc dynamic var gifFrameRate: String {
        get {
            return String(UserDefaults.standard[.gifFrameRate] ?? "20")
        }
        set {
            UserDefaults.standard[.gifFrameRate] = newValue
        }
    }

    var movieQualityTitle: String {
        let movieQualityString: String = UserDefaults.standard[.movieQuality] ?? "480p"
        switch movieQualityString {
        case AVAssetExportPresetAppleM4V720pHD: return "720p"
        case AVAssetExportPresetAppleM4V1080pHD: return "1080p"
        default: return "480p"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        gifFrameRateStepper.integerValue = Int(gifFrameRate) ?? 20
        movieQualityPopUpButton.selectItem(withTitle: movieQualityTitle)
    }

    @IBAction func selectMovieQuality(_ sender: NSPopUpButton) {
        let selectedString = sender.titleOfSelectedItem ?? "480p"
        var selectedMovieQuality: String!

        switch selectedString {
        case "720p": selectedMovieQuality = AVAssetExportPresetAppleM4V720pHD
        case "1080p": selectedMovieQuality = AVAssetExportPresetAppleM4V1080pHD
        default: selectedMovieQuality = AVAssetExportPresetAppleM4V480pSD
        }

        UserDefaults.standard[.movieQuality] = selectedMovieQuality
    }
}
