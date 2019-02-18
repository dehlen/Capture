import Foundation

class MarkdownWriter {
    static func img(title: String, url: String) -> String {
        return "[\(title)](\(url))"
    }
}
