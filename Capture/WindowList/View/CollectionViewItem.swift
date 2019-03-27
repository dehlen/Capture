import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet private weak var iconImageView: NSImageView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var appIconImageView: NSImageView!

    private var typedView: CollectionViewItemView {
        //swiftlint:disable:next force_cast
        return self.view as! CollectionViewItemView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appIconImageView.alphaValue = 0.5
    }

    override var isSelected: Bool {
        didSet {
            typedView.selected = isSelected
        }
    }

    func configure(image: NSImage?, title: String, appIcon: NSImage?) {
        iconImageView.image = image
        titleLabel.stringValue = title
        appIconImageView.image = appIcon
    }
}
