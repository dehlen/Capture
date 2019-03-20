import Foundation

enum VideoPlayerError: Error {
    case noCurrentItem
    case missingFile
    case exportFailed
}
