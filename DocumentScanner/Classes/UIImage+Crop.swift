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

    func flatten() -> UIImage {
        let ciImage = CIImage(image: self)!

        let ciContext =  CIContext()

        let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                  context: ciContext,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!

        let rect = detector.features(in: ciImage).first as! CIRectangleFeature



        let flattenedImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [

            "inputTopLeft": CIVector(cgPoint: rect.topLeft),
            "inputTopRight": CIVector(cgPoint: rect.topRight),
            "inputBottomLeft": CIVector(cgPoint: rect.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: rect.bottomRight)


            ])

        UIGraphicsBeginImageContext(CGSize(width: flattenedImage.extent.size.height, height: flattenedImage.extent.size.width))

        UIImage(ciImage:ciImage,scale:1.0,orientation:.right).draw(in: CGRect(x: 0, y: 0, width: ciImage.extent.size.height, height: ciImage.extent.size.width))

        let image = UIGraphicsGetImageFromCurrentImageContext()


        UIGraphicsEndImageContext()
        return image!

    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
