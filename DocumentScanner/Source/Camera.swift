import UIKit
import AVFoundation
import Vision

open class Camera: NSObject {

    private let capturePhotoOutput = AVCapturePhotoOutput()
    private let videoDataOutputQueue = DispatchQueue(
        label: "VideoDataOutputQueue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)

    private(set) var scannerView        = ScannerView()
    private(set) var observationRect = ObservationRectangle()

    private (set) var rectDetector = RectangleDetector()

    var bufferSize: CGSize = .zero

    var onPhotoCapture: ((UIImage) -> Void)?

    lazy var videoDevice: AVCaptureDevice? = {
        let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back).devices.first

        do {
            try videoDevice?.lockForConfiguration()
           // let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            //bufferSize.width = CGFloat(dimensions.width)
            //bufferSize.height = CGFloat(dimensions.height)
            videoDevice?.unlockForConfiguration()
        } catch {
            print(error)
        }

        return videoDevice
    }()

    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        guard
            let backCamera = videoDevice,
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

    init(detector: RectangleDetector) {
        super.init()

        self.rectDetector = detector

        Utils.subscribeToDeviceOrientationNotifications(self, selector: #selector(deviceOrientationDidChange(_:)))
    }

    func prepareForSession(prepared: (AVCaptureVideoPreviewLayer, ScannerView) -> Void) {
        scannerView.cameraView.layer.addSublayer(cameraLayer)

        prepared(cameraLayer, scannerView)
    }

    func configureAndStartSessiion() {

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        captureSession.addOutput(videoOutput)

        captureSession.beginConfiguration()

        capturePhotoOutput.isHighResolutionCaptureEnabled = true

        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        captureSession.commitConfiguration()

        // set initial video orientation
        updateConnectionOrientation()

        startSession()

        observeDetectorOutput()
        observeScannerViewActions()
    }

    func startSession() {
        scannerView.captureButton.isEnabled = true
        captureSession.startRunning()
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        if let superView = scannerView.superview {
            scannerView.frame.size = superView.frame.size
            cameraLayer.frame.size = superView.frame.size
        }

        // Change video orientation to always display video in correct orientation
        updateConnectionOrientation()
    }

    private func updateConnectionOrientation() {
        guard let connection = cameraLayer.connection else { return }
        connection.videoOrientation = Utils.videoOrientationFromDeviceOrientation(
          videoOrientation: connection.videoOrientation)
    }

    private func observeDetectorOutput() {        
        rectDetector.onRectDetect = { [weak self]
            rect, newFrame in

            guard let `self` = self else { return }

            self.observationRect = rect

            let flippedRect = rect.flipped

            let topLeft     = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: flippedRect.topLeft)
            let topRight    = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: flippedRect.topRight)
            let bottomRight = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: flippedRect.bottomRight)
            let bottomLeft  = self.cameraLayer.layerPointConverted(fromCaptureDevicePoint: flippedRect.bottomLeft)

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
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true

//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [
//            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//            kCVPixelBufferWidthKey as String: 160,
//            kCVPixelBufferHeightKey as String: 160
//        ]
//
//        settings.previewPhotoFormat = previewFormat

        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    open func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {

        // make sure the pixel buffer can be converted
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        rectDetector.detect(from: pixelBuffer)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension Camera: AVCapturePhotoCaptureDelegate {
    open func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?) {

        guard let data = photo.fileDataRepresentation() else { return }

        guard let image = UIImage(data: data) else { return }

        onPhotoCapture?(image)
    }
}
