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
        let croppedUIImage = UIImage(
            cgImage: cgImage,
            scale: self.scale,
            orientation: self.imageOrientation
        )

        return croppedUIImage
    }

    var flattened: UIImage? {
        let ciImage = CIImage(image: self)!

        guard let openGLContext = EAGLContext(api: .openGLES2) else { return nil }
        let ciContext =  CIContext(eaglContext: openGLContext)

        let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                  context: ciContext,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!

        guard let rect = detector.features(in: ciImage).first as? CIRectangleFeature
            else { return nil }

        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topLeft),
                                       forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topRight),
                                       forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.bottomRight),
                                       forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint :rect.bottomLeft),
                                       forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage,
                                       forKey: kCIInputImageKey)


        if let output = perspectiveCorrection.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent) {
            
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return nil
    }

    func flattened(rect: ObservationRectangle) -> UIImage? {
        let ciImage = CIImage(image: self)!

        let topLeft     = rect.topLeft.scaled(to: ciImage.extent.size)
        let topRight    = rect.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft  = rect.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = rect.bottomRight.scaled(to: ciImage.extent.size)

        guard let openGLContext = EAGLContext(api: .openGLES2) else { return nil }
        let ciContext =  CIContext(eaglContext: openGLContext)

        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
        perspectiveCorrection.setValue(CIVector(cgPoint: topLeft),
                                       forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: topRight),
                                       forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: bottomRight),
                                       forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: bottomLeft),
                                       forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage,
                                       forKey: kCIInputImageKey)

        if
            let output = perspectiveCorrection.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent) {

            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return nil
    }

    var noiseReducted: UIImage {
        guard let openGLContext = EAGLContext(api: .openGLES2) else { return self }
        let ciContext = CIContext(eaglContext: openGLContext)

        guard let noiseReduction = CIFilter(name: "CINoiseReduction") else { return self }
        noiseReduction.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        noiseReduction.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReduction.setValue(0.40, forKey: "inputSharpness")

        if let output = noiseReduction.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return self
    }

    var grayscaled: UIImage {
        guard let openGLContext = EAGLContext(api: .openGLES2) else { return self }
        let ciContext = CIContext(eaglContext: openGLContext)

        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return self }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return self
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
