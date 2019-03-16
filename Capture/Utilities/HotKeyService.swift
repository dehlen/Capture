import Foundation
import Cocoa
import Magnet

final class HotKeyService: NSObject {
    fileprivate(set) var stopRecordingKeyCombo: KeyCombo?
}

// MARK: - Actions
extension HotKeyService {
    @objc func stopRecording() {
        Current.notificationCenter.post(name: .shouldStopRecording, object: nil)
    }
}

// MARK: - Setup
extension HotKeyService {
    func setupDefaultHotKeys() {
        change(with: .stopRecording, keyCombo: savedKeyCombo(forKey: Constants.HotKey.stopRecordingKeyCombo))
    }

    func change(with type: HotKeyType, keyCombo: KeyCombo?) {
        switch type {
        case .stopRecording:
            stopRecordingKeyCombo = keyCombo
        }
        register(with: type, keyCombo: keyCombo)
    }

    private func savedKeyCombo(forKey key: String) -> KeyCombo? {
        guard let data = Current.defaults.object(forKey: key) as? Data else { return nil }
        guard let keyCombo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? KeyCombo else { return nil }
        return keyCombo
    }
}

// MARK: - Register
private extension HotKeyService {
    func register(with type: HotKeyType, keyCombo: KeyCombo?) {
        save(with: type, keyCombo: keyCombo)
        // Reset hotkey
        HotKeyCenter.shared.unregisterHotKey(with: type.rawValue)
        // Register new hotkey
        guard let keyCombo = keyCombo else { return }
        let hotKey = HotKey(identifier: type.rawValue, keyCombo: keyCombo, target: self, action: type.hotKeySelector)
        hotKey.register()
    }

    func save(with type: HotKeyType, keyCombo: KeyCombo?) {
        Current.defaults.set(keyCombo?.archive(), forKey: type.userDefaultsKey)
        Current.defaults.synchronize()
    }
}
