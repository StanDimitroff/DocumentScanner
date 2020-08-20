import UIKit

struct ObservationRectangle {
    var topLeft: CGPoint     = .zero
    var topRight: CGPoint    = .zero
    var bottomRight: CGPoint = .zero
    var bottomLeft: CGPoint  = .zero

    static var zero: ObservationRectangle {
        return .init()
    }

    var isEmpty: Bool {
        return topLeft     == .zero &&
               topRight    == .zero &&
               bottomRight == .zero &&
               bottomLeft  == .zero
    }

    var flipped: ObservationRectangle {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .portrait, .landscapeLeft, .faceUp:
            return ObservationRectangle(
                topLeft: CGPoint(x: topLeft.x, y: 1 - topLeft.y),
                topRight: CGPoint(x: topRight.x, y: 1 - topRight.y),
                bottomRight: CGPoint(x: bottomRight.x, y: 1 - bottomRight.y),
                bottomLeft: CGPoint(x: bottomLeft.x, y: 1 - bottomLeft.y)
            )

        case .landscapeRight:
            return ObservationRectangle(
                topLeft: CGPoint(x: 1 - topLeft.x, y: topLeft.y),
                topRight: CGPoint(x: 1 - topRight.x, y: topRight.y),
                bottomRight: CGPoint(x: 1 - bottomRight.x, y: bottomRight.y),
                bottomLeft: CGPoint(x: 1 - bottomLeft.x, y: bottomLeft.y)
            )

        case .portraitUpsideDown:
            return ObservationRectangle(
                topLeft: self.bottomLeft,
                topRight: self.topLeft,
                bottomRight: self.topRight,
                bottomLeft: self.bottomRight
            )

        default:
            return self
        }
    }
}
