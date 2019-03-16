import Foundation

enum FinishState {
    case success(_ gifOutputUrl: URL?)
    case failure(_ message: String)
}
