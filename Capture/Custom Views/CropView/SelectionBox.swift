import Cocoa

class SelectionBox: CAShapeLayer {
    @objc let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")

    override init() {
        super.init()

        self.lineWidth = 0.5
        self.lineJoin = CAShapeLayerLineJoin.round
        self.strokeColor = NSColor.black.cgColor
        self.fillColor = NSColor.clear.cgColor
        self.lineDashPattern = [5, 5]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func initializeAnimation() {
        dashAnimation.fromValue = 10.0
        dashAnimation.toValue = 0.0
        dashAnimation.duration = 0.75
        dashAnimation.repeatCount = 100
        self.add(dashAnimation, forKey: "linePhase")
    }
}
