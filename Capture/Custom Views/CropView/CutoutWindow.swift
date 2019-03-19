import AppKit

class CutoutWindow: NSWindow {
    private var cropView: CropView?

    convenience init(contentRect: NSRect,
                     styleMask style: NSWindow.StyleMask,
                     backing backingStoreType: NSWindow.BackingStoreType,
                     defer flag: Bool,
                     cutout: NSRect) {
        self.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        cropView = CropView(frame: contentRect)
        contentView = cropView
        cropView?.showCrop(at: cutout)
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = NSWindow.Level.statusBar
        ignoresMouseEvents = false
        displaysWhenScreenProfileChanges = true
    }

    var cutoutFrame: NSRect {
        return cropView?.cropBox ?? .zero
    }

    var directDisplayId: CGDirectDisplayID {
        if NSScreen.screens.count > 1, let displayId = screen?.displayID {
            return displayId
        }

        return CGMainDisplayID()
    }

    func recordingStarted() {
        ignoresMouseEvents = true
        contentView = CutoutView(frame: frame, cutout: cutoutFrame)
        cropView = nil
    }
}

public extension NSScreen {
    public var displayID: CGDirectDisplayID? {
        return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
}

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
