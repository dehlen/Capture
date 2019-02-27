import AppKit

extension NSView {
    func addSubView(_ view: NSView, animated: Bool) {
        view.alphaValue = 0
        view.setFrameOrigin(.zero)

        let duration = animated ? (window?.currentEvent?.modifierFlags.contains(.shift) == true ? 1.0 : 0.25) : 0.0

        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = duration
        addSubview(view)
        view.animator().alphaValue = 1.0
        NSAnimationContext.endGrouping()
    }

    func removeFromSuperview(animated: Bool) {
        let duration = animated ? (window?.currentEvent?.modifierFlags.contains(.shift) == true ? 1.0 : 0.25) : 0.0
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = duration
        animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.removeFromSuperview()
        }
    }
}
