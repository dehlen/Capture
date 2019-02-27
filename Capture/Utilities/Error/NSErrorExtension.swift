import Foundation

extension NSError {
    static func create(from error: Error) -> NSError {
        return NSError(domain: "com.davidehlen.Capture", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error",                 NSLocalizedRecoverySuggestionErrorKey: ErrorMessageProvider.string(for: error)])
    }
}
