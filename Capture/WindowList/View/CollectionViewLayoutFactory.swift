import AppKit

class CollectionViewLayoutFactory {
    static func createGridLayout() -> NSCollectionViewGridLayout {
        let gridLayout = NSCollectionViewGridLayout()

        gridLayout.minimumItemSize = NSSize(width: 120, height: 90)
        gridLayout.maximumItemSize = NSSize(width: 240, height: 180)
        gridLayout.minimumInteritemSpacing = 10
        gridLayout.minimumLineSpacing = 10
        gridLayout.margins = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        return gridLayout
    }
}
