import Cocoa
import AVFoundation
import Magnet
import os
import AboutWindowFramework

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Variables
    let updater = AppUpdater(owner: Constants.Repo.owner, repo: Constants.Repo.name)

    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()

    lazy var aboutWindowControllerConfig: AboutWindowControllerConfig = {
        let website = URL(string: Constants.Repo.url)

        return AboutWindowControllerConfig(creditsButtonTitle: "credits".localized,
                                           eula: nil,
                                           eulaButtonTitle: "eula".localized,
                                           url: website,
                                           hasShadow: true)
    }()

    lazy var aboutWindowController: AboutWindowController = {
        return AboutWindowController.create(with: aboutWindowControllerConfig)
    }()

    // MARK: - Lifecycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        os_log(.info, log: .app, "Application did finish launching")
        setupPreferenceDefaults()
        askForAccessibilityPermission()
        ValueTransformerFactory.registerAll()
        Current.hotKeyService.setupDefaultHotKeys()
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
}

// MARK: - Actions
extension AppDelegate {
    @IBAction private func showPreferences(_ sender: Any) {
        os_log(.info, log: .preferences, "Preferences shown")
        preferencesWindowController?.showWindow(sender)
    }

    @IBAction private func showAboutWindow(_ sender: AnyObject) {
        aboutWindowController.showWindow(self)
    }

    @IBAction private func openVideo(_ sender: Any) {
        Alerts.showOpenDialog { (result) in
            openExportWindow(file: result)
        }
    }
}

// MARK: - Functions
extension AppDelegate {
    private func openExportWindow(file: URL) {
        let containerViewController = ContainerViewController.create(videoUrl: file)
        let window = NSWindow(contentViewController: containerViewController)
        window.makeKeyAndOrderFront(NSApp)
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

    private func askForAccessibilityPermission() {
        os_log(.info, log: .app, "Ask for accessibility control")
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let myDict: CFDictionary = NSDictionary(dictionary: [promptFlag: true])
        AXIsProcessTrustedWithOptions(myDict)
    }
        if let data = keyCombo?.archive() {
            Current.defaults.register(defaults: [
                Constants.HotKey.stopRecordingKeyCombo: data
            ])
        }
    }
}
