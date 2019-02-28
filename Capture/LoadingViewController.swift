import AppKit

class LoadingViewController: NSViewController {
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()

        progressIndicator.startAnimation(nil)
    }
}
