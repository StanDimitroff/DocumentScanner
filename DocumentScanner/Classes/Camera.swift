//
//  Camera.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import AVFoundation

@available (iOS 11.0, *)
final class Camera: NSObject {
    
    private let rectDetector       = RectangleDetector()
    private let capturePhotoOutput = AVCapturePhotoOutput()

    private var scannerView        = ScannerView()
    private(set) var observationRect = ObservationRectangle()

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

    func configureAndStartSessiion() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        captureSession.addOutput(videoOutput)

        captureSession.beginConfiguration()

        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        captureSession.commitConfiguration()

        startSession()

        observeDetectorOutput()
        observeScannerViewActions()
    }

    func startSession() {
        captureSession.startRunning()
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    private func observeDetectorOutput() {        
        rectDetector.onRectDetect = { [weak self]
            rect, newFrame in

            guard let `self` = self else { return }

            self.observationRect = rect

            let topLeft     = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: rect.topLeft)
            let topRight    = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: rect.topRight)
            let bottomRight = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: rect.bottomRight)
            let bottomLeft  = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: rect.bottomLeft)

            self.scannerView.observationRect = ObservationRectangle(
                topLeft: topLeft,
                topRight: topRight,
                bottomRight: bottomRight,
                bottomLeft: bottomLeft)
        }
    }

    private func observeScannerViewActions() {
        scannerView.onImageCapture = { [weak self] in

            guard let `self` = self else { return }

            self.capturePhoto()
        }
    }

    private func capturePhoto() {
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
@available(iOS 11.0, *)
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
@available(iOS 11.0, *)
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
