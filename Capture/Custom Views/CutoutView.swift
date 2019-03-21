import Cocoa

class CutoutView: NSView {
    var cutout: NSRect = .zero
    var cutoutLayer: CAShapeLayer?

    convenience init(frame frameRect: NSRect, cutout: NSRect) {
        self.init(frame: frameRect)
        self.cutout = cutout
    }

    func dashedLineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer.init()

        let cropViewLineWidth: CGFloat = 3
        let cropLineFrame = NSRect(
            x: cutout.origin.x - cropViewLineWidth,
            y: cutout.origin.y - cropViewLineWidth,
            width: cutout.width + cropViewLineWidth * 2.0,
            height: cutout.height + cropViewLineWidth * 2.0
        )

        let path = NSBezierPath(roundedRect: cropLineFrame, xRadius: 0, yRadius: 0)
        layer.path = path.CGPath
        layer.strokeColor = NSColor.red.cgColor
        layer.lineDashPattern = nil
        layer.lineCap = CAShapeLayerLineCap.round
        layer.lineWidth = cropViewLineWidth
        layer.backgroundColor = NSColor.clear.cgColor
        layer.fillColor = NSColor.clear.cgColor

        return layer
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.5).set()
        bounds.fill()
        cutout.fill(using: .clear)

        if cutoutLayer == nil {
            cutoutLayer = dashedLineLayer()
            layer?.addSublayer(cutoutLayer!)
        }
    }
}
