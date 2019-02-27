import Foundation

extension UserDefaults {
    public struct Key: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

    func set<T>(_ value: T?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    func value<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    subscript<T>(key: Key) -> T? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key) }
    }

    func register(defaults: [Key: Any]) {
        let mapped = Dictionary(uniqueKeysWithValues: defaults.map { (key, value) in
            return (key.rawValue, value)
        })

        self.register(defaults: mapped)
    }

}
