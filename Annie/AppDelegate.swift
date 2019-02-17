import Cocoa
import UserNotifications
import AVFoundation

#warning("show crop on screen during recording")
#warning("app icon")
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print(NSString(string:"~/Desktop/HCCQR.txt").expandingTildeInPath)
        setupNotificationCenter()
        setupPreferenceDefaults()
        ValueTransformerFactory.registerAll()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupPreferenceDefaults() {
        let defaults = UserDefaults.standard

        defaults.register(defaults: [
            .sendNotifications: true,
            .exportUrl: DirectoryHandler.desktopUrl!.path,
            .movieQuality: AVAssetExportPresetAppleM4V480pSD,
            .gifFrameRate: 20,
            .gifHeight: 720
        ])
    }

    @IBAction func showPreferences(_ sender: Any) {
        preferencesWindowController?.showWindow(sender)
    }

    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if let error = error {
                print(error)
            }
        }

        let openGifAction = UNNotificationAction(identifier: LocalNotification.Action.openGif, title: "Open".localized, options: [.foreground])

        let category = UNNotificationCategory(identifier: LocalNotification.Category.newGif, actions: [openGifAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func handleNotification(response: UNNotificationResponse) {
        switch response.actionIdentifier {
        case LocalNotification.Action.openGif:
            let userInfo = response.notification.request.content.userInfo
            guard let gifUrlString = userInfo["gifUrl"] as? String, let url = URL(string: gifUrlString) else { return }
            NSWorkspace.shared.open(url)
        default: ()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(response: response)
        completionHandler()
    }
}

