import Cocoa

class PreferencesViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = NSSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        parent?.view.window?.title = self.title!
    }
}
