import AppKit

class CutoutWindow: NSWindow {
    private var cropView: CropView?

    convenience init(contentRect: NSRect,
                     styleMask style: NSWindow.StyleMask,
                     backing backingStoreType: NSWindow.BackingStoreType,
                     defer flag: Bool,
                     cropViewDelegate: CropViewDelegate?) {
        self.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        cropView = CropView(frame: contentRect)
        cropView?.delegate = cropViewDelegate
        contentView = cropView
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
        guard let cropView = cropView else { return .zero }
        return cropView.isInFullscreen ? .zero : cropView.cropBox
    }

    var directDisplayId: CGDirectDisplayID {
        if NSScreen.screens.count > 1, let displayId = screen?.displayID {
            return displayId
        }

        return CGMainDisplayID()
    }

    func recordingStarted() {
        ignoresMouseEvents = true
        cropView?.removeFromSuperview()
        contentView = CutoutView(frame: frame, cutout: cutoutFrame)
        cropView = nil
    }

    func cancel() {
        cropView?.cancel()
    }

    func showCrop(at frame: CGRect, initial: Bool) {
        cropView?.showCrop(at: frame, initial: initial)
    }
}
