import Foundation
import Cocoa
import os

class SandboxDirectoryAccess {
    static let shared: SandboxDirectoryAccess = SandboxDirectoryAccess()
    private var bookmarks = [URL: Data]()

    init() {}

    func openFolderSelection(then handler: @escaping (URL?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result == .OK {
                let url = openPanel.url
                handler(url)
                self.storeFolderInBookmark(url: url!)
            }
        }
    }

    func saveBookmarksData() {
        let path = getBookmarkPath()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: bookmarks, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            os_log(.default, log: .sandbox, "Could not save bookmark data")
        }
    }

    func loadBookmarks() {
        let path = getBookmarkPath()
        bookmarks = [:]
        if let data = try? Data(contentsOf: path) {
            if let unarchived = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) {
                bookmarks = unarchived as? [URL: Data] ?? [:]
            }
            for bookmark in bookmarks {
                restoreBookmark(bookmark)
            }
        }
    }

    private func storeFolderInBookmark(url: URL) {
        do {
            let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            bookmarks[url] = data
        } catch {
            os_log(.default, log: .sandbox, "Error storing bookmarks")
        }
    }

    private func getBookmarkPath() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return url.appendingPathComponent("Bookmarks.dict")
    }

    private func restoreBookmark(_ bookmark: (key: URL, value: Data)) {
        let restoredUrl: URL?
        var isStale = false

        os_log(.info, log: .sandbox, "Restoring %{public}@", bookmark.key.absoluteString)

        do {
            restoredUrl = try URL(resolvingBookmarkData: bookmark.value, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        } catch {
            os_log(.default, log: .sandbox, "Error restoring bookmarks")
            restoredUrl = nil
        }

        if let url = restoredUrl {
            if isStale {
                os_log(.info, log: .sandbox, "URL is stale")
            } else {
                if !url.startAccessingSecurityScopedResource() {
                    os_log(.default, log: .sandbox, "Couldn't access: %{public}@", url.path)
                }
            }
        }
    }

}
