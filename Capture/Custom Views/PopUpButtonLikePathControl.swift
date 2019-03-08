import AppKit

class PopUpButtonLikePathControl: NSPathControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
}

extension PopUpButtonLikePathControl: NSPathControlDelegate {
    // Hack because NSPathControler is broken as hell
    // see: https://stackoverflow.com/questions/12673664/how-do-i-set-the-selected-item-in-a-nspathcontrol-in-popup-style/14796181#14796181
    func pathControl(_ pathControl: NSPathControl, willPopUp menu: NSMenu) {
        while menu.items.count >= 4 {
            menu.removeItem(at: 3)
        }
    }
}
