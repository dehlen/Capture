import AppKit

class Alerts {
    static func showAlert(title: String, message: String) {
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    static func showAlert(title: String, message: String, action: Action) {
        #warning("check if firstButton is correct and check whether buttons are shown")
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: action.title)
        alert.addButton(withTitle: "cancel".localized)
        alert.alertStyle = NSAlert.Style.warning

        if alert.runModal() == .alertFirstButtonReturn {
            action.run()
        }
    }

    static func showOpenDialog(configure: ((NSOpenPanel) -> Void)? = nil, completion: (URL) -> Void) {
        let dialog = NSOpenPanel()
        dialog.title = "chooseVideoFile".localized
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["public.movie"]
        configure?(dialog)

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let result = dialog.url {
                completion(result)
            }
        }
    }
}
