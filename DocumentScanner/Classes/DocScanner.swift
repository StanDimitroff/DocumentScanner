//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit
import AVFoundation

public final class DocScanner {

    /// UIViewController instance where scanner will be presented
    public var presenter: UIViewController!

    private var camera: Camera
    private let rectDetector = RectangleDetector()

    /// Exports scanned image
    public var onImageExport: ((UIImage) -> Void)?

    /// Construct scanner object
    public init() {
        camera = Camera(rectDetector)
    }

    /// Start scanning
    public func startSession() {
        camera.prepareForSession {
            cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame
            presenter.view.addSubview(scannerView)
        }
        
        camera.startSession()
        observeCameraOutput()

        toggleIdle(disabled: true)
    }

    /// Stop scanning
    public func stopSession() {
        camera.stopSession()
        toggleIdle(disabled: false)
    }

    private func observeCameraOutput() {
        camera.onPhotoCapture = { [weak self]
            photo in

            guard let `self` = self else { return }

            let cropRect = self.camera.scannerView.trackView.frame
            let croppedImage = photo.crop(toPreviewLayer: self.camera.cameraLayer, withRect: cropRect)

            self.onImageExport?(croppedImage)
        }
    }

    private func toggleIdle(disabled: Bool) {
         UIApplication.shared.isIdleTimerDisabled = disabled
    }
}


