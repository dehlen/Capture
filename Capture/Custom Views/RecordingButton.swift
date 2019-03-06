import Cocoa

@IBDesignable class RecordingButton: NSButton {
    @IBInspectable var outerCircleColor: NSColor = NSColor.white.withAlphaComponent(0.7)
    @IBInspectable var innerCircleColor: NSColor = NSColor.red

    var isRecording: Bool = false {
        didSet {
            setNeedsDisplay(self.frame)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        outerCircleColor.setFill()
        __NSRectFill(dirtyRect)

        layer?.cornerRadius = dirtyRect.width / 2

        let innerCircleFrame = NSRect(x: dirtyRect.minX + 5, y: dirtyRect.minY + 5, width: dirtyRect.width - 10, height: dirtyRect.height - 10)
        let innerSquareFrame = NSRect(x: dirtyRect.minX + 7, y: dirtyRect.minY + 7, width: dirtyRect.width - 14, height: dirtyRect.height - 14)
        let path = isRecording ? NSBezierPath(rect: innerSquareFrame) : NSBezierPath(ovalIn: innerCircleFrame)
        innerCircleColor.setFill()
        path.fill()

        super.draw(dirtyRect)
    }
}
