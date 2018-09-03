import UIKit

open class CornerView: UIView {

    enum Position {
        case topLeft, topRight, bottomRight, bottomLeft
    }

    let position: Position

    init(position: Position) {
        self.position = position
        
        super.init(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = self.bounds.width / 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.5
    }
}
