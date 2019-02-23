import AppKit

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
}
