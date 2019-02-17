import Foundation

infix operator ≈
infix operator …

@discardableResult
public func with<T: AnyObject>(_ obj: T, _ body: (T) throws -> Void) rethrows -> T {
    try body(obj)
    return obj
}
public func with<T>(_ value: T, _ body: (inout T) throws -> Void) rethrows -> T {
    var valueCopy = value
    try body(&valueCopy)
    return valueCopy
}

public func ≈<T>(value: T, body: (inout T) throws -> Void) rethrows -> T {
    return try with(value, body)
}
@discardableResult
public func …<T: AnyObject>(obj: T, body: (T) throws -> Void) rethrows -> T {
    return try with(obj, body)
}

public typealias Ignored = Int
public typealias UnusedKVOValue = AnyObject?
