import Cocoa

class StatusBarItemController {
    private var statusItem: NSStatusItem?
    weak var delegate: StatusBarItemControllerDelegate?

    func addStopRecordingItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let statusItem = statusItem else { return }
        statusItem.button?.image = NSImage(imageLiteralResourceName: "stopRecording")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusBarItemClicked)
    }

    func removeStopRecordingItem() {
        guard let statusItem = statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    @objc private func statusBarItemClicked() {
        delegate?.didClickStatusBarItem()
    }
}
