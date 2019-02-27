import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var appIconImageView: NSImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.appIconImageView.alphaValue = 0.5
    }

    override var isSelected: Bool {
        willSet {
            view.layer?.backgroundColor = newValue ? NSColor.blue.cgColor : NSColor.clear.cgColor
        }
    }
}
