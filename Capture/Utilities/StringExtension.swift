import Foundation

extension String {
    var mov: String { return "\(self).mov" }
    var gif: String { return "\(self).gif" }

    var fileName: String { return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent }
    var fileNameWithExtension: String { return URL(fileURLWithPath: self).lastPathComponent }

    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
