import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!


    override var isSelected: Bool {
        willSet {
            view.layer?.backgroundColor = newValue ? NSColor.blue.cgColor : NSColor.clear.cgColor
        }
    }
}
