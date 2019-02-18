import AppKit

extension NSViewController {
    public func loadViewIfNeeded() {
        if !isViewLoaded {
            loadView()
        }
    }

    public func embed(_ vc: NSViewController, container: NSView? = nil) {
        addChild(vc)
        #warning("views are not resizable")
        let targetView = container ?? view
        var frame = CGRect(x: 0, y: 0, width: targetView.frame.width, height: targetView.frame.height)
        if frame.size.width == 0 {
            frame.size.width = CGFloat.leastNormalMagnitude
        }
        if frame.size.height == 0 {
            frame.size.height = CGFloat.leastNormalMagnitude
        }
        vc.view.frame = frame
        targetView.addSubView(vc.view, animated: true)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: targetView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: targetView.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: targetView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: targetView.bottomAnchor),

        ])
    }

    public func remove(_ vc: NSViewController) {
        vc.view.removeFromSuperview(animated: true)
        vc.removeFromParent()
    }
}
