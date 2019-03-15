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
        self.fillColor = NSColor(calibratedRed: 0.1054, green: 0.4531, blue: 0.7929, alpha: 1.0).cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
