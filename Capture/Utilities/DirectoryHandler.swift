import Foundation
import os

struct DirectoryHandler {
    static var videoDestination: URL {
        let dateFormatter = Current.dateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let timestamp = dateFormatter.string(from: Current.date())
        return FileManager.default.temporaryDirectory.appendingPathComponent("ScreenRecording \(timestamp.mov)")
    }

    static var exportFolder: URL {
        #warning("set downloads directory as default in preference ui, provide open dialog in settings to change directory sandbox compatible")
        guard let exportUrlPath: String = Current.defaults[.exportUrl] else {
            return createDefaultExportDirectory()
        }
        return URL(fileURLWithPath: exportUrlPath)
    }

    static var downloadsDirectory: URL {
        guard let downloadsDirectory = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            else { fatalError("Could not find downloads directory") }
        return downloadsDirectory
    }

    static func createDefaultExportDirectory() -> URL {
        let url = downloadsDirectory.appendingPathComponent(Bundle.main.appName ?? "Capture")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        } catch {
            return downloadsDirectory
        }
    }

    static func copy(from videoUrl: URL, to destination: URL? = nil) {
        let destinationUrl = destination ?? exportFolder.appendingPathComponent(videoUrl.path.fileName.mov)
        do {
            try FileManager.default.copyItem(at: videoUrl, to: destinationUrl)
        } catch let error {
            os_log(.error, log: .app, "Could not copy file from %{public}@, %{public}@", videoUrl.path, error.localizedDescription)
        }
    }
}
