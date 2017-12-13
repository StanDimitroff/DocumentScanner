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

    /// Construct scanner object
    public init(presenter: UIViewController) {
        self.presenter = presenter
    }

    /// Start scanning
    public func startSession() {
        camera.prepareForSession {
            cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame
            presenter.view.addSubview(scannerView)
        }
        
        camera.configureAndStartSessiion()
        observeCameraOutput()

        toggleIdle(disabled: true)
    }

    /// Stop scanning
    public func stopSession() {
        camera.stopSession()
        toggleIdle(disabled: false)
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
                    self.camera.startSession()
                }
                                                                               
                cropView.onRegionSave = {
                    region in

                    self.cropImage(photo, withRegion: region)
                }

                self.presenter.view.addSubview(cropView)

                // stop camera when editing
                self.camera.stopSession()

                return
           // }

           // self.cropImage(photo, withRegion: regionRect)
        }
    }

    private func cropImage(_ photo: UIImage, withRegion region: CGRect) {
        let croppedImage = photo.crop(toPreviewLayer: camera.cameraLayer, withRect: region)

        onImageExport?(croppedImage)
    }

    private func cropImage(_ photo: UIImage, withRegion region: UIBezierPath) {
        let croppedImage = photo.imageByApplyingClippingBezierPath(region)

        onImageExport?(croppedImage)
    }

    private func toggleIdle(disabled: Bool) {
         UIApplication.shared.isIdleTimerDisabled = disabled
    }
}


