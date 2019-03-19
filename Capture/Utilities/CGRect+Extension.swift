import Foundation

extension CGRect {
    func centerRect(withSize size: CGFloat) -> CGRect {
        return CGRect(x: width / 2 - size / 2, y: height / 2 - size / 2, width: size, height: size)
    }
}
