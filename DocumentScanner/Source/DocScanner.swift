//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit

@available (iOS 11.0, *)
@objcMembers public final class DocScanner: NSObject {
    public typealias ImageExport = (UIImage) -> Void
    public typealias Dismiss = () -> Void

    private var presenter: UIViewController
    private var camera = Camera(detector: RectangleDetector())

    private var exportImage: ImageExport?
    private var dismiss: Dismiss?

    /// Minimum confidence score, range [0.0, 1.0], defaults to 0.6
    public var minimumConfidence: Float = 0.6

    /// Minimum size of the document to be detected, range [0.0, 1.0], defaults to 0.3
    public var minimumSize: Float = 0.3

    /// Maximum number of degrees a document corner angle can deviate from 90 degrees, range [0,45], defaults to 45
    public var quadratureTolerance: Float = 45

    /// Minimum aspect ratio of the rectangle(s) to look for, range [0.0, 1.0], defaults to 0.5
    public var minimumAspectRatio: Float = 0.5

    /// Maximum aspect ratio of the document to look for, range [0.0, 1.0], defaults to 1.0
    public var maximumAspectRatio: Float = 1.0

    /// Construct scanner object
    public init(presenter: UIViewController) {
        self.presenter = presenter
    }

    /// Configuring scanner using `VNDetectRectanglesRequest` parameters. If not provided defaults are used.
    /// Can be called runtime durring the scanner session
    ///
    /// - Parameter block: Block of actions to perform (set parameters)
    /// - Returns: Running DocScanner instance
    /// - Throws: Error if cannot execute block
    public func config(_ block: (DocScanner) throws -> Void) rethrows -> Self {
        try block(self)

        camera.rectDetector.config {
            $0.minimumConfidence    = minimumConfidence
            $0.minimumSize          = minimumSize
            $0.quadratureTolerance  = quadratureTolerance
            $0.minimumAspectRatio   = minimumAspectRatio
            $0.maximumAspectRatio   = maximumAspectRatio
        }

        return self
    }

    /// Start scanning
    @discardableResult
    public func startSession() -> Self {
        assert(!camera.captureSession.isRunning, "Scanner is already running")
        
        camera.prepareForSession {
            cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame

            scannerView.onDismiss = {
                self.dismiss?()
                self.stopSession()
            }
            
            presenter.view.addSubview(scannerView)
        }
        
        camera.configureAndStartSessiion()
        observeCameraOutput()

        toggleIdle(disabled: true)

        return self
    }

    /// Restore stopped scanner session
    public func continueSession() {
        assert(!camera.captureSession.isRunning, "Scanner is already running")

        camera.startSession()
        toggleIdle(disabled: true)
    }

    /// Stop scanning
    public func stopSession() {
        if camera.captureSession.isRunning {
            camera.stopSession()
            //Utils.unsubscribeFromOrientationNotifications(camera)
            toggleIdle(disabled: false)
        }
    }

    private func observeCameraOutput() {
        camera.onPhotoCapture = {
            photo in

            if let flattened = photo.flattened(rect: self.camera.observationRect) {
                self.exportImage?(flattened.noiseReducted)
                self.stopSession()

                return
            }

            // manual crop
            let cropView = CroppView(frame: self.presenter.view.frame)
            cropView.imageView.image = photo
            cropView.observationRect = self.camera.observationRect

            // return from manual cropping
            cropView.onRetake = {
                self.continueSession()
            }

            cropView.onRegionSave = {
                region in

                if let flattened = photo.flattened(rect: region) {
                    self.exportImage?(flattened.noiseReducted)
                    self.stopSession()

                    return
                }

                self.cropImage(photo, withRegion: region)
            }

            self.presenter.view.addSubview(cropView)

            // stop session when editing
            self.stopSession()

            return
        }
    }

    private func cropImage(_ photo: UIImage, withRegion region: ObservationRectangle) {
        // calculate the crop region with the very near corners from path
        let origin = CGPoint(
            x: max(region.topLeft.x, region.bottomLeft.x),
            y: max(region.topLeft.y, region.topRight.y))

        let size = CGSize(
            width: min(region.topRight.x, region.bottomRight.x) - origin.x,
            height: min(region.bottomLeft.y, region.bottomRight.y) - origin.y)

        let regionRect = CGRect(origin: origin, size: size)

        let croppedImage = photo.crop(toPreviewLayer: camera.cameraLayer, withRect: regionRect)

        exportImage?(croppedImage.noiseReducted)
        stopSession()
    }

    private func toggleIdle(disabled: Bool) {
         UIApplication.shared.isIdleTimerDisabled = disabled
    }

    /// Exports scanned image
    ///
    /// - Parameter closure: A closure with exported image
    /// - Returns: Running `DocScanner` instance
    @discardableResult
    public func exportImage(_ closure: @escaping ImageExport) -> Self {
        exportImage = closure
        return self
    }

    /// Dismisses scanner
    ///
    /// - Parameter closure: dismiss closure
    /// - Returns: Running `DocScanner` instance
    public func dismiss(_ closure: @escaping Dismiss) -> Self {
        dismiss = closure
        return self
    }
}
