//
//  Camera.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import AVFoundation

final class Camera: NSObject {
    
    private let rectDetector       = RectangleDetector()
    private let capturePhotoOutput = AVCapturePhotoOutput()

    private(set) var scannerView   = ScannerView()
    private(set) var documentRect  = CGRect()

    var onPhotoCapture: ((UIImage) -> Void)?

    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        guard
            let backCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }

        session.addInput(input)

        return session
    }()

    lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill

        return layer
    }()

    func prepareForSession(prepared: (AVCaptureVideoPreviewLayer, ScannerView) -> ()) {
        scannerView.cameraView.layer.addSublayer(cameraLayer)

        prepared(cameraLayer, scannerView)
    }

    func startSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        captureSession.addOutput(videoOutput)

        configureSessiion()

        captureSession.startRunning()

        observeDetectorOutput()
        observeScannerViewActions()
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    private func configureSessiion() {
        captureSession.beginConfiguration()

        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        captureSession.commitConfiguration()
    }

    private func observeDetectorOutput() {
        rectDetector.onRectDetect = { [weak self]
            newFrame in

            guard let `self` = self else { return }

            // calculate view rect
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: newFrame)

            if convertedRect.isNull ||
               convertedRect.isEmpty ||
               convertedRect.isInfinite {
                self.scannerView.trackView.frame = .zero
                self.documentRect = .zero

                return
            }
            
            self.scannerView.trackView.frame = convertedRect
            self.scannerView.trackView.isHidden = false
            self.documentRect = convertedRect
        }
    }

    private func observeScannerViewActions() {
        scannerView.onImageCapture = { [weak self] in

            guard let `self` = self else { return }

            self.capturePhoto()
        }

        scannerView.onDismiss = { [weak self] in
            guard let `self` = self else { return }

            self.stopSession()
        }
    }

    private func capturePhoto() {
        //assert(!documentRect.isEmpty, "Rect of interest could not be empty: \(documentRect)")

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isAutoStillImageStabilizationEnabled = true
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        
        settings.previewPhotoFormat = previewFormat

        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {

        // make sure the pixel buffer can be converted
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        rectDetector.detect(on: pixelBuffer)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?) {

        guard let data = photo.fileDataRepresentation() else { return }

        guard let image = UIImage(data: data) else { return }

        onPhotoCapture?(image)
    }
}


