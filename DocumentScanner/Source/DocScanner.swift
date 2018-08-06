//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit

@available (iOS 11.0, *)
public final class DocScanner: NSObject {
    public typealias ImageExport = (UIImage) -> Void
    public typealias Dismiss = () -> Void

    private var presenter: UIViewController
    private let camera = Camera()

    private var exportImage: ImageExport?
    private var dismiss: Dismiss?

    /// Construct scanner object
    public init(presenter: UIViewController) {
        self.presenter = presenter
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
    /// - Returns: DocScanner
    @discardableResult
    public func exportImage(_ closure: @escaping ImageExport) -> Self {
        exportImage = closure
        return self
    }

    /// Dismisses scanner
    ///
    /// - Parameter closure: dismiss closure
    /// - Returns: DocScanner
    public func dismiss(_ closure: @escaping Dismiss) -> Self {
        dismiss = closure
        return self
    }
}
