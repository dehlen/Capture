import AppKit

class CollectionViewDataSource<Model>: NSObject, NSCollectionViewDataSource {
    typealias ItemConfigurator = (Model, NSCollectionViewItem) -> Void

    var models: [Model]

    private let itemIdentifier: NSUserInterfaceItemIdentifier
    private let itemConfigurator: ItemConfigurator

    init(models: [Model],
         itemIdentifier: NSUserInterfaceItemIdentifier,
         itemConfigurator: @escaping ItemConfigurator) {
        self.models = models
        self.itemIdentifier = itemIdentifier
        self.itemConfigurator = itemConfigurator
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let model = models[indexPath.item]
        let item = collectionView.makeItem(
            withIdentifier: itemIdentifier,
            for: indexPath)

        itemConfigurator(model, item)

        return item
    }
}

extension CollectionViewDataSource where Model == WindowInfo {
    static func make(for windows: [WindowInfo],
                     itemIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem")
        ) -> CollectionViewDataSource {
        return CollectionViewDataSource(
            models: windows,
            itemIdentifier: itemIdentifier
        ) { (window, item) in
            guard let item = item as? CollectionViewItem else { return }
            let title = window.name.isEmpty ? window.ownerName : "\(window.ownerName)\n\(window.name)"
            item.configure(image: window.image, title: title, appIcon: window.appIconImage)
        }
    }
}
