import Cocoa

// MARK: Bezier Path Extension -
// From https://gist.github.com/juliensagot/9749c3a1df28c38fb9f9
extension NSBezierPath {
    var CGPath: CGPath {
        return self.transformToCGPath()
    }

    /// Transform this NSBezierPath into a CGPathRef
    fileprivate func transformToCGPath() -> CGPath {
        // Create path
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount

        if numElements > 0 {
            var didClosePath = true

            for index in 0..<numElements {
                let pathType = self.element(at: index, associatedPoints: points)

                switch pathType {
                case .moveTo:
                    path.move(to: CGPoint(x: points[0].x, y: points[0].y))
                case .lineTo:
                    path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
                    didClosePath = false
                case .curveTo:
                    path.addCurve(
                        to: CGPoint(x: points[2].x, y: points[2].y),
                        control1: CGPoint(x: points[0].x, y: points[0].y),
                        control2: CGPoint(x: points[1].x, y: points[1].y)
                    )
                    didClosePath = false
                case .closePath:
                    path.closeSubpath()
                    didClosePath = true
                }
            }

            if !didClosePath {
                path.closeSubpath()
            }
        }

        points.deallocate()
        return path
    }
}
