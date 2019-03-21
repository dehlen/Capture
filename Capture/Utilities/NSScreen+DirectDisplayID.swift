import AppKit

public extension NSScreen {
    public var displayID: CGDirectDisplayID? {
        return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
}
