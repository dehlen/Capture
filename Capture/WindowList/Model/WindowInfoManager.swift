import AppKit
import os

class WindowInfoManager {
    static func allWindows() -> [WindowInfo] {
        let windowInfosRef = CGWindowListCopyWindowInfo(
            [CGWindowListOption.optionAll, CGWindowListOption.excludeDesktopElements],
            kCGNullWindowID
        )
        var items: [WindowInfo] = []

        for i in 0..<CFArrayGetCount(windowInfosRef) {
            let lineUnsafePointer: UnsafeRawPointer = CFArrayGetValueAtIndex(windowInfosRef, i)
            let lineRef = unsafeBitCast(lineUnsafePointer, to: CFDictionary.self)
            let dic = lineRef as Dictionary<NSObject, AnyObject>

            let info = WindowInfo(item: dic as! [String : AnyObject])
            if info.isNormalWindow {
                items.append(info)
            }
        }

        return items
    }

    static func updateWindow(windowInfo: WindowInfo?) -> WindowInfo? {
        guard let windowInfo = windowInfo else { return nil }
        return allWindows().filter { $0.id == windowInfo.id }.first
    }

    static func switchToApp(withWindowId id: CGWindowID) {
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        guard let infoList = windowListInfo as NSArray? as? [[String: AnyObject]] else { return }
        if let window = infoList.first(where: { ($0["kCGWindowNumber"] as? Int32) == Int32(id)}), let pid = window["kCGWindowOwnerPID"] as? Int32 {
            let app = NSRunningApplication(processIdentifier: pid)
            app?.activate(options: .activateIgnoringOtherApps)
        }
    }
}
