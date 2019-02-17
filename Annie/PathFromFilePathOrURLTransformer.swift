import Foundation

extension NSValueTransformerName {
	static let pathFromFilePathOrURLTransformerName = NSValueTransformerName(rawValue: "PathFromFilePathOrURLTransformer")
}

class PathFromFilePathOrURLTransformer : ValueTransformer {
	override class func transformedValueClass() -> AnyClass {
		return NSURL.self
	}
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		guard let pathWithTilde = value as? String else {
			return value
		}

        let path = (pathWithTilde as NSString).expandingTildeInPath
		let url = URL(fileURLWithPath: path)

        return url
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		switch value {
		case nil:
			return nil
		case let url as URL:
			return url.path
		case let path as String:
			return path
		default:
			assert(false)
			return value
		}
	}
}
