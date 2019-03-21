import Foundation

class WindowListViewModel {
    var windows: [WindowInfo] = []
    weak var delegate: WindowListViewControllerDelegate? {
        didSet {
            refresh()
        }
    }
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.refresh()
        }
    }

    private func refresh() {
        reloadWindows()
        delegate?.didRefreshWindowList()
    }

    private func reloadWindows() {
        windows.removeAll()

        windows = WindowInfoManager.allWindows()
    }

    func window(at index: Int) -> WindowInfo? {
        if index >= windows.count {
            return nil
        }

        return windows[index]
    }
}
