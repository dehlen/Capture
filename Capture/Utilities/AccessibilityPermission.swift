import Cocoa
import os

func hasAccessibilityPermission() -> Bool {
    let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
    let myDict: CFDictionary = NSDictionary(dictionary: [promptFlag: false])
    return AXIsProcessTrustedWithOptions(myDict)
}

func askForAccessibilityPermission() {
    os_log(.info, log: .app, "Ask for accessibility control")
    Alerts.showAlert(title: "accessibilityPermissionTitle".localized,
              message: "accessibilityPermissionMessage".localized,
              action: Action(title: "openSystemSettings".localized, run: {
                guard let accessibilitySettingsPaneUrl = URL(string: Constants.SystemPreferences.urlScheme)
                    else {
                        os_log(.error, log: .app, "Could not show accessibility permission dialog. The app probably won't record videos correctly.")
                        return
                }
                NSWorkspace.shared.open(accessibilitySettingsPaneUrl)
                NSRunningApplication
                    .runningApplications(withBundleIdentifier: Constants.SystemPreferences.bundleIdentifier)
                    .first?
                    .activate(options: .activateIgnoringOtherApps)
              })
    )
}
