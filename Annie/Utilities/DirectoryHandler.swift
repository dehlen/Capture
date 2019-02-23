import Foundation

struct DirectoryHandler {
    static var videoDestination: URL {
        let dateFormatter = Current.dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let timestamp = dateFormatter.string(from: Current.date())
        return FileManager.default.temporaryDirectory.appendingPathComponent("ScreenRecording \(timestamp.mov)")
    }

    static var exportFolder: URL? {
        guard let exportUrlPath: String = Current.defaults[.exportUrl] else {
            return desktopUrl
        }
        return URL(fileURLWithPath: exportUrlPath)
    }

    static var desktopUrl: URL? {
        return try? FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
}
