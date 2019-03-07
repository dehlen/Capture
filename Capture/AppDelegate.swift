import Cocoa
import AVFoundation
import Magnet
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()

    let updater = AppUpdater(owner: "dehlen", repo: "Capture")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        os_log(.info, log: .app, "Application did finish launching")
        setupPreferenceDefaults()
        ValueTransformerFactory.registerAll()
        Current.hotKeyService.setupDefaultHotKeys()
        askForAccessibilityPermission()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        os_log(.info, log: .app, "Application will terminate")
        // Insert code here to tear down your application
    }

    private func setupPreferenceDefaults() {
        os_log(.info, log: .app, "Setting preference defaults")
        Current.defaults.register(defaults: [
            .exportUrl: DirectoryHandler.desktopUrl!.path,
            .movieQuality: AVAssetExportPresetAppleM4V480pSD,
            .gifFrameRate: 20,
            .gifHeight: 480,
            .gifWidth: 0,
            .showMouseCursor: true,
            .showMouseClicks: true,
            .saveVideo: true
        ])
        
        let keyCombo = KeyCombo(keyCode: 15, carbonModifiers: 4352)
            if let data = keyCombo?.archive() {
                Current.defaults.register(defaults: [
                    Constants.HotKey.stopRecordingKeyCombo: data
                ])
        }
    }

    private func askForAccessibilityPermission() {
        os_log(.info, log: .app, "Ask for accessibility control")
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = NSDictionary(dictionary: [promptFlag: true])
        AXIsProcessTrustedWithOptions(myDict)
    }

    @IBAction func showPreferences(_ sender: Any) {
        os_log(.info, log: .preferences, "Preferences shown")
        preferencesWindowController?.showWindow(sender)
    }
}
