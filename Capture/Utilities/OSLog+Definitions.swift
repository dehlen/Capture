import os.log
import Foundation

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let app = OSLog(subsystem: subsystem, category: "App")
    static let mainScreen = OSLog(subsystem: subsystem, category: "MainScreen")
    static let bitBucket = OSLog(subsystem: subsystem, category: "BitBucket")
    static let exportContainer = OSLog(subsystem: subsystem, category: "ExportContainer")
    static let videoPlayer = OSLog(subsystem: subsystem, category: "VideoPlayer")
    static let preferences = OSLog(subsystem: subsystem, category: "Preferences")
    static let gifExport = OSLog(subsystem: subsystem, category: "GIFExport")
    static let videoRecorder = OSLog(subsystem: subsystem, category: "VideoRecorder")
    static let windowHandling = OSLog(subsystem: subsystem, category: "WindowHandling")
}
