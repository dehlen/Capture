import Foundation

class MarkdownWriter {
    static func link(title: String, url: String) -> String {
        return "[\(title)](\(url))"
    }

    static func img(attachment: Attachment) -> String {
        let href = attachment.links.attachment.href
        return "[![\((attachment.url as NSString).lastPathComponent)](\(href))](\(href))"
    }
}
