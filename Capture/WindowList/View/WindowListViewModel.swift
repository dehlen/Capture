import Foundation

struct WindowListViewModel {
    var windows: [WindowInfo] = []

    mutating func reloadWindows() {
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
