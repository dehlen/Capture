import AppKit

func showAlert(title: String, message: String) {
    let alert = NSAlert.init()
    alert.messageText = title
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
