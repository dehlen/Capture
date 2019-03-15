import Cocoa

class SelectionHandler: CAShapeLayer {
    var location: NSPoint = .zero {
        didSet {
            self.path = NSBezierPath(ovalIn: NSRect.handlerRectForPoint(location)).CGPath
        }
    }

    override init() {
        super.init()

        self.lineWidth = 2.0
        self.strokeColor = NSColor.white.cgColor
        self.fillColor = NSColor.gray.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
