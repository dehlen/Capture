import Cocoa

@IBDesignable class RecordingButton: NSButton {
    @IBInspectable var outerCircleColor: NSColor = NSColor.white.withAlphaComponent(0.7)
    @IBInspectable var innerCircleColor: NSColor = NSColor.red

    override func draw(_ dirtyRect: NSRect) {
        outerCircleColor.setFill()
        __NSRectFill(dirtyRect)

        layer?.cornerRadius = dirtyRect.width / 2

        let innerCircleFrame = NSRect(x: dirtyRect.minX + 5, y: dirtyRect.minY + 5, width: dirtyRect.width - 10, height: dirtyRect.height - 10)
        let path = NSBezierPath(ovalIn: innerCircleFrame)
        innerCircleColor.setFill()
        path.fill()

        super.draw(dirtyRect)
    }
}
