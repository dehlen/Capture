import Cocoa

class PreferencesViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        parent?.view.window?.title = self.title!
    }
}
