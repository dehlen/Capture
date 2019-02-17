import Foundation

extension NSValueTransformerName {
    static let numberValueTransformerName = NSValueTransformerName(rawValue: "NumberValueTransformer")
}

class NumberValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let number = value as? NSNumber else { return nil }
        return String(number.intValue)
    }
}
