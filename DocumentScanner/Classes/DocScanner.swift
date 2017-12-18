//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit

public final class DocScanner {

    private var presenter: UIViewController
    private var camera = Camera()

    /// Exports scanned image
    public var onImageExport: ((UIImage) -> Void)?

    /// Dismiss scanner handler
    public var onDismiss: (() -> Void)?

    /// Construct scanner object
    public init(presenter: UIViewController) {
        self.presenter = presenter
    }

    /// Start scanning
    public func startSession() {
        assert(!camera.captureSession.isRunning, "Scanner is already running")
        
        camera.prepareForSession {
            cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame

            scannerView.onDismiss = {
                self.onDismiss?()
                self.stopSession()
            }
            
            presenter.view.addSubview(scannerView)
        }
        
        camera.configureAndStartSessiion()
        observeCameraOutput()

        toggleIdle(disabled: true)
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

            let regionRect = self.camera.documentRect

            //assert(!cropRect.isEmpty, "Cannot crop image with empty region: \(cropRect)")

            //if cropRect.isEmpty {
                let cropView = CroppView(frame: self.presenter.view.frame)
                cropView.imageView.image = photo

                cropView.trackedRegion = regionRect

                // return from manual cropping
                cropView.onRetake = {
                    self.continueSession()
                }
                                                                               
                cropView.onRegionSave = {
                    region in

                    self.cropImage(photo, withRegion: region)
                }

                self.presenter.view.addSubview(cropView)

                // stop session when editing
                self.stopSession()

                return
           // }

           // self.cropImage(photo, withRegion: regionRect)
        }
    }

    private func cropImage(_ photo: UIImage, withRegion region: CGRect) {
        let croppedImage = photo.crop(toPreviewLayer: camera.cameraLayer, withRect: region)

        onImageExport?(croppedImage)
        stopSession()
    }

    private func toggleIdle(disabled: Bool) {
         UIApplication.shared.isIdleTimerDisabled = disabled
    }
}


