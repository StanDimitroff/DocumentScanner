//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit
import AVFoundation

public final class DocScanner: NSObject {

    public var presenter: UIViewController!

    private var camera: Camera
    private let rectDetector = RectangleDetector()

    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: camera.captureSession)
        layer.frame = presenter.view.bounds
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()

    private var scannerView: ScannerView!

    public var onImageExport: ((UIImage) -> Void)?

    var lastFrame = CGRect.zero

    public override init() {
        camera = Camera(rectDetector)

        super.init()
    }

    public func startSession() {
        scannerView = ScannerView(frame: presenter.view.frame)
        scannerView.cameraView.layer.addSublayer(cameraLayer)
        presenter.view.addSubview(scannerView)
        
        camera.startSession()

        observeDetectorOutput()
        observePhotoOutput()
    }

    private func observeDetectorOutput() {
        rectDetector.onRectDetect = { [weak self]
            newFrame in

            guard let `self` = self else { return }

            if newFrame == .zero {
                self.scannerView.trackView.frame = newFrame
                return
            }

            // calculate view rect
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: newFrame)
            self.scannerView?.trackView.frame = convertedRect
            self.lastFrame = newFrame
        }
    }

    private func observePhotoOutput() {
        scannerView.onImageCapture = { [weak self] in
            guard let `self` = self else { return }
            self.camera.capturePhoto()
        }

        camera.photoTaken = { [weak self]
            image in

            guard let `self` = self else { return }

            let croppedImage =  image.cropImage(toRect:  self.lastFrame)

            let previewView = PreviewView(frame: self.presenter.view.frame)
            previewView.imageView.image = croppedImage

            self.scannerView.removeFromSuperview()
            self.presenter.view.addSubview(previewView)

            //self.scannerView?.imageView.image = croppedImage

           // self.scannerView?.imageView.isHidden = false
        }
    }
}


