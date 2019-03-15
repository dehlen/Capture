import Cocoa

class OverlayBox: CAShapeLayer {
    override init() {
        super.init()

        self.fillColor = NSColor(calibratedWhite: 0.5, alpha: 0.8).cgColor
        self.fillRule = CAShapeLayerFillRule.evenOdd
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
