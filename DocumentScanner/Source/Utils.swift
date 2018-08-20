import UIKit
import AVFoundation

class Utils {

    // Subscribes target to default NotificationCenter .UIDeviceOrientationDidChange
    static func subscribeToDeviceOrientationNotifications(_ target: AnyObject, selector: Selector) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        let center = NotificationCenter.default
        let name =  NSNotification.Name.UIDeviceOrientationDidChange
        let selector = selector
        center.addObserver(target, selector: selector, name: name, object: nil)
    }

    static func unsubscribeFromOrientationNotifications(_ target: AnyObject) {
        let center = NotificationCenter.default
        center.removeObserver(target)

        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    static func videoOrientationFromDeviceOrientation(
        videoOrientation: AVCaptureVideoOrientation) -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .unknown:
            return videoOrientation
        case .portrait:
            // Device oriented vertically, home button on the bottom
            return .portrait
        case .portraitUpsideDown:
            // Device oriented vertically, home button on the top
            return .portraitUpsideDown
        case .landscapeLeft:
            // Device oriented horizontally, home button on the right
            return .landscapeRight
        case .landscapeRight:
            // Device oriented horizontally, home button on the left
            return .landscapeLeft
        case .faceUp:
            // Device oriented flat, face up
            return videoOrientation
        case .faceDown:
            // Device oriented flat, face down
            return videoOrientation
        }
    }

    static func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch deviceOrientation {
        case .portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case .landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case .landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case .portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
