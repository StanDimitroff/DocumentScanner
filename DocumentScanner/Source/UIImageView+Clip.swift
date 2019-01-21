import UIKit

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }

        let imageSize = image.size
        guard imageSize.width > 0 && imageSize.height > 0 else { return bounds }

        let scale: CGFloat
        if imageSize.width > imageSize.height {
            scale = bounds.width / imageSize.width
        } else {
            scale = bounds.height / imageSize.height
        }

        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let xCoord = (bounds.width - size.width) / 2.0
        let yCoord = (bounds.height - size.height) / 2.0

        return CGRect(x: xCoord, y: yCoord, width: size.width, height: size.height)
    }
}
