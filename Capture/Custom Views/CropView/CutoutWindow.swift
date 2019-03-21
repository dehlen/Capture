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
