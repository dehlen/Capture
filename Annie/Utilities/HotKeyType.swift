import Foundation

enum HotKeyType: String {
    case stopRecording = "RecordingHotKey"

    var userDefaultsKey: String {
        switch self {
        case .stopRecording:
            return Constants.HotKey.stopRecordingKeyCombo
        }
    }

    var hotKeySelector: Selector {
        switch self {
        case .stopRecording:
            return #selector(HotKeyService.stopRecording)
        }
    }
}
