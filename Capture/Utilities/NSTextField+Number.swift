import AppKit

extension NSTextField {
    var numberValue: Double {
        return NumberFormatter().number(from: stringValue)?.doubleValue ?? 0
    }
}
