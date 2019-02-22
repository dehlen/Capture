import Foundation
import Cocoa

struct WindowInfo {
    var order: Int?
    var id: CGWindowID?
    var name = ""
    var ownerName = ""
    var layer: Int32 = 0
    var frame = NSRect.zero
    var image: NSImage = NSImage()
    var alpha: Int = 0
    var directDisplayID: CGDirectDisplayID?

    private let cropViewLineWidth: CGFloat = 3.0
    private let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
    private var windowOwnerPid: pid_t?
    lazy private var quartzScreenFrame: CGRect? = {
        return CGDisplayBounds(self.directDisplayID!)
    }()

    var appIconImage: NSImage? {
        guard let windowOwnerPid = windowOwnerPid else { return nil }
        let runningApplication = NSRunningApplication(processIdentifier: windowOwnerPid)
        return runningApplication?.icon
    }

    func directDisplayID(from frame: CGRect) -> CGDirectDisplayID {
        let unsafeDirectDisplayID = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: 1)
        unsafeDirectDisplayID.pointee = 1
        CGGetDisplaysWithRect(frame, 2, unsafeDirectDisplayID, nil)
        let directDisplayID = unsafeDirectDisplayID.pointee as CGDirectDisplayID
        return directDisplayID
    }

    init(item: [String: AnyObject]) {
        windowOwnerPid = item[String(kCGWindowOwnerPID)] as? pid_t
        name = item[String(kCGWindowName)] as? String ?? ""
        ownerName = item[String(kCGWindowOwnerName)] as? String ?? ""
        layer = (item[String(kCGWindowLayer)] as! NSNumber).int32Value
        id = (item[String(kCGWindowNumber)] as! NSNumber).uint32Value
        alpha = (item[String(kCGWindowAlpha)] as! NSNumber).intValue

        if let id = id {
            image = NSImage.windowImage(with: id)
        }

        let bounds = item[String(kCGWindowBounds)] as! Dictionary<String, CGFloat>

        let cgFrame = NSRect(
            x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!
        )

        var windowFrame = NSRectFromCGRect(cgFrame)
        directDisplayID = directDisplayID(from: windowFrame)
        windowFrame.origin = convertPosition(windowFrame)

        let differencialValue = cropViewLineWidth - CGFloat(2)
        let optimizeFrame = NSRect(
            x: windowFrame.origin.x - differencialValue,
            y: windowFrame.origin.y - differencialValue,
            width: windowFrame.width + differencialValue * 2.0,
            height: windowFrame.height + differencialValue * 2.0
        )

        frame = optimizeFrame
    }

    func convertPosition(_ frame:NSRect) -> NSPoint {
        //TODO: do not use mainDisplayBounds here 
        var convertedPoint = frame.origin
        let y = mainDisplayBounds.height - frame.height - frame.origin.y
        convertedPoint.y = y
        return convertedPoint
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
}

private extension NSImage {
    static func windowImage(with windowId: CGWindowID) -> NSImage {
        if let screenShot = CGWindowListCreateImage(CGRect.null, .optionIncludingWindow, CGWindowID(windowId), CGWindowImageOption()) {
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let image = NSImage()
            image.addRepresentation(bitmapRep)
            return image
        } else {
            return NSImage()
        }
    }
}
