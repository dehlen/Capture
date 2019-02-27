import Foundation

public struct World {
    var calendar = Calendar.autoupdatingCurrent
    var date = { Date() }
    var locale = Locale.autoupdatingCurrent
    var timeZone = TimeZone.autoupdatingCurrent
    var hotKeyService = HotKeyService()
    var defaults = UserDefaults.standard
    var notificationCenter = NotificationCenter.default
}

#if DEBUG
public var Current = World()
#else
public let Current = World()
#endif

public extension World {
    public func dateFormatter(dateStyle: DateFormatter.Style = .none, timeStyle: DateFormatter.Style = .none) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle

        formatter.calendar = self.calendar
        formatter.locale = self.locale
        formatter.timeZone = self.timeZone

        return formatter
    }
}
