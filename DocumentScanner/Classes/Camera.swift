//
//  Camera.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import AVFoundation

final class Camera: NSObject {

    var photoTaken: ((UIImage) -> Void)?
    
    private let rectDetector: RectangleDetector
    private let capturePhotoOutput = AVCapturePhotoOutput()

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

    init(_ rectDetector: RectangleDetector) {
        self.rectDetector = rectDetector
    }

    func startSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        captureSession.addOutput(videoOutput)

        configureSessiion()

        captureSession.startRunning()
    }

    private func configureSessiion() {
        captureSession.beginConfiguration()

        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        captureSession.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat

        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
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
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?) {

        guard let data = photo.fileDataRepresentation() else { return }

        guard let image = UIImage(data: data) else { return }

        photoTaken?(image)
    }
}


