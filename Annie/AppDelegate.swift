import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupPreferenceDefaults()
        ValueTransformerFactory.registerAll()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupPreferenceDefaults() {
        let defaults = UserDefaults.standard

        defaults.register(defaults: [
            .exportUrl: DirectoryHandler.desktopUrl!.path,
            .movieQuality: AVAssetExportPresetAppleM4V480pSD,
            .gifFrameRate: 20,
            .gifHeight: 720,
            .bitBucketApiEndpoint: bitbucketBaseURL,
            .showMouseCursor: true,
            .showMouseClicks: true
        ])
    }

    @IBAction func showPreferences(_ sender: Any) {
        preferencesWindowController?.showWindow(sender)
    }
}
