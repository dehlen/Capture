import AppKit
import os

class GIFOptionViewController: NSViewController {
    @IBOutlet private weak var gifFrameRateStepper: NSStepper!

    @objc dynamic var gifHeight: String {
        get {
            return String(Current.defaults[.gifHeight] ?? "480")
        }
        set {
            if newValue.isNumeric {
                Current.defaults[.gifHeight] = newValue
            }
        }
    }

    @objc dynamic var gifWidth: String {
        get {
            return String(Current.defaults[.gifWidth] ?? "0")
        }
        set {
            if newValue.isNumeric {
                Current.defaults[.gifWidth] = newValue
            }
        }
    }

    @objc dynamic var gifFrameRate: String {
        get {
            return String(Current.defaults[.gifFrameRate] ?? "30")
        }
        set {
            Current.defaults[.gifFrameRate] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, log: .videoPlayer, "Showing gif export options")
    }
}
