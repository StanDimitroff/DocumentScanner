//
//  UIImage+Crop.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 21.11.17.
//

import UIKit
import AVFoundation

extension UIImage {

    func crop(toPreviewLayer layer: AVCaptureVideoPreviewLayer, withRect rect: CGRect) -> UIImage {
        let outputRect = layer.metadataOutputRectConverted(fromLayerRect: rect)
        var cgImage = self.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(
            x: outputRect.origin.x * width,
            y: outputRect.origin.y * height,
            width: outputRect.size.width * width,
            height: outputRect.size.height * height)

        cgImage = cgImage.cropping(to: cropRect)!
        let croppedUIImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)

        return croppedUIImage
    }

    func crop(region: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(region.bounds.size, false, self.scale)

        if let currentContext = UIGraphicsGetCurrentContext() {
            region.layer.render(in: currentContext)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage//?.resized(original: self)
    }

    func resized(original: UIImage) -> UIImage {
        let size = original.size
            UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: size))

            guard let context = UIGraphicsGetImageFromCurrentImageContext() else { return self }
            return context
    }

    func imageByApplyingClippingBezierPath(_ path: UIBezierPath) -> UIImage {
        // Mask image using path
        let maskedImage = imageByApplyingMaskingBezierPath(path)

        // Crop image to frame of path
        let croppedImage = UIImage(cgImage: maskedImage.cgImage!.cropping(to: path.bounds)!)
        return croppedImage
    }

    func imageByApplyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage {
        // Define graphic context (canvas) to paint on
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        // Set the clipping mask
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!

        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()

        return maskedImage
    }

    func clip(_ path: UIBezierPath) -> UIImage! {
        let frame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        self.draw(in: frame)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
