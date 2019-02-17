import Foundation

struct ErrorMessageProvider {
    static func string(for error: Error) -> String {
        if let error = error as? UserInterfaceError {
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
}
