//
//  UIImage+Crop.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 21.11.17.
//

import UIKit

extension UIImage {

    func crop(to: CGRect) -> UIImage {
        guard let cgimage = self.cgImage else { return self }

        let contextImage: UIImage = UIImage(cgImage: cgimage)

        let contextSize: CGSize = contextImage.size

        //Set to square
        var posX: CGFloat = to.origin.x
        var posY: CGFloat = to.origin.y
        let cropAspect: CGFloat = to.width / to.height

        var cropWidth: CGFloat = to.size.width
        var cropHeight: CGFloat = to.size.height

//        if to.width > to.height { //Landscape
//            cropWidth = contextSize.width
//            cropHeight = contextSize.width / cropAspect
//            posY = (contextSize.height - cropHeight) / 2
//        } else if to.width < to.height { //Portrait
//            cropHeight = contextSize.height
//            cropWidth = contextSize.height * cropAspect
//            //posX = (contextSize.width - cropWidth) / 2
//        } else { //Square
//            if contextSize.width >= contextSize.height { //Square on landscape (or square)
//                cropHeight = contextSize.height
//                cropWidth = contextSize.height * cropAspect
//                //posX = (contextSize.width - cropWidth) / 2
//            }else{ //Square on portrait
//                cropWidth = contextSize.width
//                cropHeight = contextSize.width / cropAspect
//                //posY = (contextSize.height - cropHeight) / 2
//            }
//        }

        //let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        // Create bitmap image from context using the rect
        //let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        //let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)


        UIGraphicsBeginImageContextWithOptions(to.size, true, self.scale)
        draw(in: CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized!
    }

//    func cropImage(toRect rect:CGRect) -> UIImage? {
//        var rect = rect
//        rect.origin.y = rect.origin.y * self.scale
//        rect.origin.x = rect.origin.x * self.scale
//        rect.size.width = rect.width * self.scale
//        rect.size.height = rect.height * self.scale
//
//        guard let imageRef = self.cgImage?.cropping(to: rect) else {
//            return nil
//        }
//
//        let croppedImage = UIImage(cgImage:imageRef)
//        return croppedImage
//    }

    func cropImage(toRect rect: CGRect) -> UIImage? {
        // Cropping is available trhough CGGraphics
        let cgImage :CGImage! = self.cgImage
        let croppedCGImage: CGImage! = cgImage.cropping(to: rect)

        return UIImage(cgImage: croppedCGImage)
    }
}
