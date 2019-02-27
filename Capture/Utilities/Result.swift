import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}
