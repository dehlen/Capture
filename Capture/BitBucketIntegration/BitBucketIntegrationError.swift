import Foundation

enum BitBucketIntegrationError: Error {
    case missingFile
    case uploadFailed
    case notAuthorized
}
