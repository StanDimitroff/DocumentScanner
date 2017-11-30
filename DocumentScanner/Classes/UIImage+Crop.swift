//
//  UIImage+Crop.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 21.11.17.
//

import UIKit

extension UIImage {

    func cropImage(toRect rect: CGRect) -> UIImage? {
        //UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        //let rect = CGRect(x: x, y: y, width: width, height: height)
        let transformedCropRect = rect.applying(transform)
        let cgImage: CGImage! = self.cgImage
        let croppedCGImage: CGImage! = cgImage.cropping(to: transformedCropRect)
        //let imageRef = CGImageCreateWithImageInRect(self.cgImage!, transformedCropRect)!
       // let croppedImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        //return croppedImage

//        let cgImage: CGImage! = self.cgImage
        //let croppedCGImage: CGImage! = cgImage.cropping(to: rect)

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
