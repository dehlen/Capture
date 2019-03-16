import Cocoa

struct WindowInfo {
    private var order: Int?
    private var layer: Int32 = 0
    private var alpha: Int = 0
    private var windowOwnerPid: pid_t?

    var ownerName = ""
    var name = ""
    var id: CGWindowID?
    var frame = NSRect.zero
    var image: NSImage = NSImage()
    var directDisplayID = CGMainDisplayID()

    var appIconImage: NSImage? {
        guard let windowOwnerPid = windowOwnerPid else { return nil }
        let runningApplication = NSRunningApplication(processIdentifier: windowOwnerPid)
        return runningApplication?.icon
    }

    init(item: [String: AnyObject]) {
        windowOwnerPid = item[String(kCGWindowOwnerPID)] as? pid_t
        name = item[String(kCGWindowName)] as? String ?? ""
        ownerName = item[String(kCGWindowOwnerName)] as? String ?? ""

        if let layerItem = item[String(kCGWindowLayer)] as? NSNumber {
            layer = layerItem.int32Value
        }

        if let idItem = item[String(kCGWindowNumber)] as? NSNumber {
            id = idItem.uint32Value
        }

        if let alphaItem = item[String(kCGWindowAlpha)] as? NSNumber {
            alpha = alphaItem.intValue
        }

        if let id = id {
            image = NSImage.windowImage(with: id)
        }

        if let bounds = item[String(kCGWindowBounds)] as? [String: CGFloat] {
            let cgFrame = NSRect(
                x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!
            )
            var windowFrame = NSRectFromCGRect(cgFrame)

            directDisplayID = directDisplayID(from: windowFrame)
            windowFrame.origin = convertPosition(windowFrame)
            frame = windowFrame
        }
    }

    var isNormalWindow: Bool {
        if alpha <= 0 {
            return false
        }
        if frame.width < 100 || frame.height < 100 {
            return false
        }
        if image.size.width < 10 || image.size.height < 10 {
            return false
        }
        if ownerName == "Dock" || ownerName == "Window Server" || ownerName == Bundle.main.displayName {
            return false
        }

        if layer != CGWindowLevelForKey(.normalWindow) {
            return false
        }

        if layer >= CGWindowLevelForKey(.mainMenuWindow) {
            return false
        }

        return true
    }

    private func directDisplayID(from frame: CGRect) -> CGDirectDisplayID {
        let unsafeDirectDisplayID = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: 1)
        unsafeDirectDisplayID.pointee = 1
        CGGetDisplaysWithRect(frame, 2, unsafeDirectDisplayID, nil)
        let directDisplayID = unsafeDirectDisplayID.pointee as CGDirectDisplayID
        return directDisplayID
    }

    private func convertPosition(_ frame: NSRect) -> NSPoint {
        var convertedPoint = frame.origin
        let displayBounds = CGDisplayBounds(directDisplayID)
        let x = frame.origin.x - displayBounds.origin.x
        let y = displayBounds.height - displayBounds.origin.y - frame.origin.y - frame.height

        convertedPoint.x = x
        convertedPoint.y = y
        return convertedPoint
    }
}
