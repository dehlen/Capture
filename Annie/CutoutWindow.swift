import AppKit

class CutoutWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
    }

    static func create(with rect: NSRect, cutout: NSRect) -> CutoutWindow {
        let window = CutoutWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: true)
        window.contentView?.addSubview(CutoutView(frame: rect, cutout: cutout))
        return window
    }
}

class CutoutView: NSView {
    var cutout: NSRect = .zero

    convenience init(frame frameRect: NSRect, cutout: NSRect) {
        self.init(frame: frameRect)
        self.cutout = cutout
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.5).set()
        bounds.fill()
        cutout.fill(using: .clear)
    }
}
