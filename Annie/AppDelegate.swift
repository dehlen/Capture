import Cocoa
import AVFoundation
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupPreferenceDefaults()
        ValueTransformerFactory.registerAll()
        Current.hotKeyService.setupDefaultHotKeys()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupPreferenceDefaults() {
        Current.defaults.register(defaults: [
            .exportUrl: DirectoryHandler.desktopUrl!.path,
            .movieQuality: AVAssetExportPresetAppleM4V480pSD,
            .gifFrameRate: 20,
            .gifHeight: 480,
            .showMouseCursor: true,
            .showMouseClicks: true
        ])
        
        let keyCombo = KeyCombo(keyCode: 15, carbonModifiers: 4352)
            if let data = keyCombo?.archive() {
                Current.defaults.register(defaults: [
                    Constants.HotKey.stopRecordingKeyCombo: data
                ])
        }
    }

    @IBAction func showPreferences(_ sender: Any) {
        preferencesWindowController?.showWindow(sender)
    }
}
