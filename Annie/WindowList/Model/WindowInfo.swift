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
        frame = windowFrame
    }

    //kCGWindowBounds returns bounds relative to the upper left corner of the main display
    //therefore we need to convert this rect in order to get the actual window location
    func convertPosition(_ frame:NSRect) -> NSPoint {
        var convertedPoint = frame.origin
        let displayBounds = CGDisplayBounds(directDisplayID ?? CGMainDisplayID())
        let x = frame.origin.x - displayBounds.origin.x
        let y = displayBounds.height - displayBounds.origin.y - frame.origin.y - frame.height

        convertedPoint.x = x
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
