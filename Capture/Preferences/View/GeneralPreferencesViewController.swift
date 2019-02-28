import Cocoa
import KeyHolder
import Magnet
import os

class GeneralPreferencesViewController: PreferencesViewController {

    // MARK: - Properties
    @IBOutlet private weak var stopRecordingShortcutRecordView: RecordView!

    // MARK: - Initialize
    override func loadView() {
        super.loadView()
        os_log(.info, log: .preferences, "Shortcut preferences loaded")
        stopRecordingShortcutRecordView.delegate = self
        setupColors()
        prepareHotKeys()
    }

}

// MARK: - Shortcut
private extension GeneralPreferencesViewController {
    func setupColors() {
        stopRecordingShortcutRecordView.backgroundColor = NSColor.windowBackgroundColor
        stopRecordingShortcutRecordView.tintColor = NSColor(red: (42/255), green: (132/255), blue: (210/255), alpha: 1.0)
        stopRecordingShortcutRecordView.borderColor = NSColor(white: 0.27, alpha: 1.0)
        stopRecordingShortcutRecordView.borderWidth = 1
        stopRecordingShortcutRecordView.cornerRadius = 17

    }

    func prepareHotKeys() {
        stopRecordingShortcutRecordView.keyCombo = Current.hotKeyService.stopRecordingKeyCombo
    }
}

// MARK: - RecordView Delegate
extension GeneralPreferencesViewController: RecordViewDelegate {
    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        return true
    }

    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        return true
    }

    func recordViewDidClearShortcut(_ recordView: RecordView) {
        switch recordView {
        case stopRecordingShortcutRecordView:
            Current.hotKeyService.change(with: .stopRecording, keyCombo: nil)
        default:
            break
        }
    }

    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        os_log(.info, log: .preferences, "Did change shortcut keycombo to modifiers: %{public}i keyCode: %{public}i", keyCombo.modifiers, keyCombo.keyCode)
        switch recordView {
        case stopRecordingShortcutRecordView:
            Current.hotKeyService.change(with: .stopRecording, keyCombo: keyCombo)
        default:
            break
        }
    }

    func recordViewDidEndRecording(_ recordView: RecordView) {}
}
