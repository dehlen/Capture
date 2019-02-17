import Foundation

class ValueTransformerFactory {
    private static let valueTransformers: [NSValueTransformerName: ValueTransformer] = [
        .numberValueTransformerName: NumberValueTransformer(),
        .pathFromFilePathOrURLTransformerName: PathFromFilePathOrURLTransformer()
    ]

    static func registerAll() {
        for (key, value) in valueTransformers {
            ValueTransformer.setValueTransformer(value, forName: key)
        }
    }
}
