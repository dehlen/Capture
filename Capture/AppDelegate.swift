import Cocoa
import AVFoundation
import Magnet
import os
import AboutWindowFramework

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()

    lazy var aboutWindowControllerConfig: AboutWindowControllerConfig = {
        let website = URL(string: "https://github.com/dehlen/Capture")

        return AboutWindowControllerConfig(creditsButtonTitle: "credits".localized,
                                           eula: nil,
                                           eulaButtonTitle: "eula".localized,
                                           url: website,
                                           hasShadow: true)
    }()

    lazy var aboutWindowController: AboutWindowController = {
        return AboutWindowController.create(with: aboutWindowControllerConfig)
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

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        openExportWindow(file: url)
        return true
    }

    private func openExportWindow(file: URL) {
        let containerViewController = ContainerViewController.create(videoUrl: file)
        let window = NSWindow(contentViewController: containerViewController)
        window.makeKeyAndOrderFront(NSApp)
    }

    @IBAction private func openVideo(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a video file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["public.movie"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let result = dialog.url {
                openExportWindow(file: result)
            }
        }
    }

    private func setupPreferenceDefaults() {
        os_log(.info, log: .app, "Setting preference defaults")
        Current.defaults.register(defaults: [
            .exportUrl: DirectoryHandler.desktopUrl!.path,
            .movieQuality: AVAssetExportPresetAppleM4V480pSD,
            .gifFrameRate: 30,
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

    @IBAction func showAboutWindow(_ sender: AnyObject) {
        aboutWindowController.showWindow(self)
    }
}
