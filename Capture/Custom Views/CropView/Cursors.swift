import Cocoa

struct Cursors {
    static func all() -> [NSCursor] {
        return [
            NSCursor(image: NSImage(named: NSImage.Name("DiagonalResizeCursor"))!, hotSpot: NSPoint(x: 9, y: 9)),
            NSCursor(image: NSImage(named: NSImage.Name("BackDiagonalResizeCursor"))!, hotSpot: NSPoint(x: 9, y: 9))
        ]
    }
}
