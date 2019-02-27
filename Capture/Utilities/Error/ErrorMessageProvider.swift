import Foundation

struct ErrorMessageProvider {
    static func string(for error: Error) -> String {
        if let error = error as? UserInterfaceError {
            return string(for: error)
        } else if let error = error as? BitBucketIntegrationError {
            return string(for: error)
        } else if let error = error as? NetworkError {
            return string(for: error)
        }
        return error.localizedDescription
    }

    private static func string(for error: UserInterfaceError) -> String {
        switch error {
        case .selectWindow:
            return "selectWindowError".localized
        }
    }

    private static func string(for error: BitBucketIntegrationError) -> String {
        switch error {
        case .missingFile:
            return "missingFile".localized
        case .uploadFailed:
            return "uploadFailed".localized
        case .notAuthorized:
            return "notAuthorized".localized
        }
    }

    private static func string(for error: NetworkError) -> String {
        switch error {
        case .missingResponse:
            return "missingResponse".localized
        }
    }
}
