import Foundation

struct ErrorMessageProvider {
    static func string(for error: Error) -> String {
        if let error = error as? UserInterfaceError {
            return string(for: error)
        } else if let error = error as? GifConversionError {
            return string(for: error)
        } else if let error = error as? VideoPlayerError {
            return string(for: error)
        } else if let error = error as? AppUpdaterError {
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

    private static func string(for error: GifConversionError) -> String {
        switch error {
        case .conversionFailed:
            return "conversionFailed".localized
        }
    }

    private static func string(for error: VideoPlayerError) -> String {
        switch error {
        case .noCurrentItem:
            return "noCurrentItem".localized
        case .missingFile:
            return "missingFile".localized
        case .exportFailed:
            return "exportFailed".localized
        }
    }

    private static func string(for error: AppUpdaterError) -> String {
        switch error {
        case .alreadyUpToDate:
            return "alreadyUpToDate".localized
        case .failure(let message):
            return String(format: "updateFailed".localized, message)
        }
    }
}
