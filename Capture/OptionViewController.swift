import AppKit
import os

class OptionViewController: NSViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, log: .mainScreen, "Showing options")
    }
}
