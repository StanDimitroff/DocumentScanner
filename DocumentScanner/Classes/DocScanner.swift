//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import AVFoundation

public final class DocScanner: NSObject {

    private var camera: Camera
    private let rectDetector = RectangleDetector()

    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: camera.captureSession)
        layer.frame = scannerView?.bounds ?? .zero
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()

    public var scannerView: ScannerView? {
        didSet {
            scannerView?.cameraView.layer.addSublayer(cameraLayer)
        }
    }

    public var onImageExport: ((UIImage) -> Void)?

    var lastFrame = CGRect.zero

    public override init() {
        let camera = Camera(rectDetector)
        self.camera = camera

        super.init()
    }

    public func startSession() {
        camera.startSession()

        observeDetectorOutput()
        observePhotoOutput()
    }

    private func observeDetectorOutput() {
        rectDetector.onRectDetect = { [weak self]
            newFrame in

            guard let `self` = self else { return }

            if newFrame == .zero {
                self.scannerView?.trackView.frame = newFrame
                return
            }

            // calculate view rect
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: newFrame)
            self.scannerView?.trackView.frame = convertedRect
            self.lastFrame = convertedRect
        }
    }

    private func observePhotoOutput() {
        scannerView?.onImageCapture = { [weak self] in
            guard let `self` = self else { return }
            self.camera.capturePhoto()
        }

        camera.photoTaken = { [weak self]
            image in

            guard let `self` = self else { return }

            let croppedImage =  image.cropImage(toRect:  self.lastFrame)
            //self.scannerView?.imageView.image = croppedImage

            //self.scannerView?.imageView.isHidden = false
        }
    }
}


