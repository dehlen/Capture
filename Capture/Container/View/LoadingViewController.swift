import AppKit

class LoadingViewController: NSViewController {
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var progressLabel: NSTextField?

    var progress: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.progressLabel?.stringValue = String(format: "%.0f %%", 100 * self.progress)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        progressIndicator.startAnimation(nil)
    }
}
