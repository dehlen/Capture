import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet private weak var iconImageView: NSImageView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var appIconImageView: NSImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.appIconImageView.alphaValue = 0.5
    }

    override var isSelected: Bool {
        willSet {
            view.layer?.backgroundColor = newValue ? NSColor.blue.cgColor : NSColor.clear.cgColor
        }
    }

    func configure(image: NSImage?, title: String, appIcon: NSImage?) {
        iconImageView.image = image
        titleLabel.stringValue = title
        appIconImageView.image = appIcon
    }
}
