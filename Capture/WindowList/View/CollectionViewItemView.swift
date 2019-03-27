import Cocoa

class CollectionViewItemView: NSView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
    }

    var selected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    override var wantsUpdateLayer: Bool {
        return true
    }

    override func updateLayer() {
        let layer = self.layer!
        layer.cornerRadius = 10.0

        switch selected {
        case true:
            layer.backgroundColor = NSColor.windowBackgroundColor.cgColor
        case false:
            layer.backgroundColor = nil
        }
    }
}
