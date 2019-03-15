import Foundation

// MARK: - NSRect Extension
extension NSRect {
    func bottomLeft() -> NSPoint {
        return NSPoint(x: origin.x, y: origin.y)
    }

    func bottomRight() -> NSPoint {
        return NSPoint(x: origin.x + size.width, y: origin.y)
    }

    func topRight() -> NSPoint {
        return NSPoint(x: origin.x + size.width, y: origin.y + size.height)
    }

    func topLeft() -> NSPoint {
        return NSPoint(x: origin.x, y: origin.y + size.height)
    }

    static func handlerRectForPoint(_ point: NSPoint) -> NSRect {
        let size = CGFloat(8.5)
        return NSRect(x: point.x - size/2, y: point.y - size/2, width: size, height: size)
    }

    mutating func moveBy(_ dx: CGFloat, dy: CGFloat) {
        origin.x += dx
        origin.y += dy
    }

    mutating func moveBy(_ dx: CGFloat, dy: CGFloat, inFrame frame: NSRect) {
        var newOrigin = origin
        newOrigin.x += dx
        newOrigin.y += dy
        newOrigin.constraintToRect(frame)

        if newOrigin.x + size.width > frame.origin.x + frame.size.width {
            newOrigin.x = frame.origin.x + frame.size.width - size.width
        }

        if newOrigin.y + size.height > frame.origin.y + frame.size.height {
            newOrigin.y = frame.origin.y + frame.size.height - size.height
        }

        origin = newOrigin
    }
}

// MARK: - NSPoint Extension
extension NSPoint {
    mutating func constraintToRect(_ rect: NSRect) {
        if x > rect.origin.x + rect.size.width {
            x = rect.origin.x + rect.size.width
        }
        if y > rect.origin.y + rect.size.height {
            y = rect.origin.y + rect.size.height
        }
        if x < rect.origin.x {
            x = rect.origin.x
        }
        if y < rect.origin.y {
            y = rect.origin.y
        }
    }

    func bufferRect(_ size: Float?=nil) -> NSRect {
        var bufferSize = CGFloat(8.5)
        if size != nil {
            bufferSize = CGFloat(size!)
        }

        return NSRect(x: x - bufferSize/2, y: y - bufferSize/2, width: bufferSize, height: bufferSize)
    }
}
