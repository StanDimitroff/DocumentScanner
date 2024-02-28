import UIKit

@objcMembers open class DocScanner: NSObject {
    public typealias ImageExport = (UIImage) -> Void
    public typealias ImagesExport = ([UIImage]) -> Void
    public typealias Dismiss = () -> Void

    private var presenter: UIViewController
    private var camera = Camera(detector: RectangleDetector())
    private var scannedImages: [UIImage] = [] {
        didSet {
            updateSaveButton()
        }
    }

    private var exportImage: ImageExport?
    private var exportImages: ImagesExport?
    private var dismiss: Dismiss?

    /// Maximum number of rectangles to be returned, defaults to 1
    public var maximumObservations: Int = 1

    /// Minimum confidence score, range [0.0, 1.0], defaults to 0.6
    public var minimumConfidence: Float = 0.6

    /// Minimum size of the document to be detected, range [0.0, 1.0], defaults to 0.3
    public var minimumSize: Float = 0.3

    /// Maximum number of degrees a document corner angle can deviate from 90 degrees, range [0,45], defaults to 45
    public var quadratureTolerance: Float = 45

    /// Minimum aspect ratio of the rectangle(s) to look for, range [0.0, 1.0], defaults to 0.5
    public var minimumAspectRatio: Float = 0.5

    /// Maximum aspect ratio of the document to look for, range [0.0, 1.0], defaults to 1.0
    public var maximumAspectRatio: Float = 1.0

    /// If true can scan and export multiple documents at onse, defaults to false
    public var exportMultiple: Bool = false
    
    ///Maximum number of scans. -1 for unlimited
    public var maximumScans = -1

    /// Construct scanner object
    public init(presenter: UIViewController) {
        self.presenter = presenter
    }

    /// Configuring scanner using `VNDetectRectanglesRequest` parameters. If not provided defaults are used.
    /// Can be called runtime durring the scanner session
    ///
    /// - Parameter block: Block of actions to perform (set parameters)
    /// - Returns: Running DocScanner instance
    /// - Throws: Error if cannot execute block
    @discardableResult
    public func config(_ block: (DocScanner) throws -> Void) rethrows -> Self {
        try block(self)

        camera.rectDetector.config {
            $0.maximumObservations  = maximumObservations
            $0.minimumConfidence    = minimumConfidence
            $0.minimumSize          = minimumSize
            $0.quadratureTolerance  = quadratureTolerance
            $0.minimumAspectRatio   = minimumAspectRatio
            $0.maximumAspectRatio   = maximumAspectRatio
        }

        return self
    }

    /// Start scanning
    @discardableResult
    public func startSession() -> Self {
        assert(!camera.captureSession.isRunning, "Scanner is already running")
        
        camera.prepareForSession { cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame

            scannerView.onDismiss = {
                Utils.unsubscribeFromOrientationNotifications(self.camera)
                
                self.dismiss?()
                self.stopSession()
            }

            scannerView.onSave = {
                self.exportMultiple ? self.exportImages?(self.scannedImages) : self.exportImage?(self.scannedImages[0])
                self.scannedImages.removeAll()
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

    private func updateSaveButton() {
        camera.scannerView.saveButton.isHidden = scannedImages.isEmpty
        camera.scannerView.captureButton.isEnabled = exportMultiple
        if scannedImages.count > 1 {
          camera.scannerView.saveButton.setTitle(
            String(format: NSLocalizedString("Save (%d)", comment: ""), scannedImages.count),
            for: .normal
          )
      }
    }

    private func observeCameraOutput() {
        camera.onPhotoCapture = {
            photo in

            // perform perspective correction
            if let flattened = photo.flattened(rect: self.camera.observationRect) {
                
                self.scannedImages.append(flattened.noiseReducted.rotated)
                
                if self.maximumScans != -1
                    && self.scannedImages.count >= self.maximumScans  {
                    self.exportMultiple ? self.exportImages?(self.scannedImages) : self.exportImage?(self.scannedImages[0])
                    self.scannedImages.removeAll()
                    self.stopSession()
                    self.dismiss?()
                }
                
                return
            }

            // manual crop
            let cropView = CroppView(frame: self.presenter.view.frame)

            cropView.image = photo.rotated
            cropView.observationRect = self.camera.observationRect

            // return from manual cropping
            cropView.onRetake = {
                self.continueSession()
                self.stopSession()
            }

            cropView.onRegionSave = {
                region in

                self.continueSession()

                // try to correct perspective with the new region
                if let flattened = photo.flattened(rect: region) {
                    self.scannedImages.append(flattened.noiseReducted.rotated)

                    if self.maximumScans != -1
                        && self.scannedImages.count >= self.maximumScans  {
                        self.exportMultiple ? self.exportImages?(self.scannedImages) : self.exportImage?(self.scannedImages[0])
                        self.scannedImages.removeAll()
                        self.stopSession()
                        self.dismiss?()
                    }
                    
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
        scannedImages.append(croppedImage.noiseReducted.rotated)
        
        if self.maximumScans != -1
            && self.scannedImages.count >= self.maximumScans  {
            self.exportMultiple ? self.exportImages?(self.scannedImages) : self.exportImage?(self.scannedImages[0])
            self.scannedImages.removeAll()
            self.stopSession()
            self.dismiss?()
        }
    }

    private func toggleIdle(disabled: Bool) {
         UIApplication.shared.isIdleTimerDisabled = disabled
    }

  /// Exports scanned image
  ///
  /// - Parameter closure: A closure with exported image
  /// - Returns: Running `DocScanner` instance
  @discardableResult
  public func exportImage(_ closure: @escaping ImageExport) -> Self {
    exportImage = closure
    return self
  }

    /// Exports multiple scanned images
    ///
    /// - Parameter closure: A closure with exported images
    /// - Returns: Running `DocScanner` instance
    @discardableResult
    public func exportImages(_ closure: @escaping ImagesExport) -> Self {
        exportImages = closure
        return self
    }

    /// Dismisses scanner
    ///
    /// - Parameter closure: dismiss closure
    /// - Returns: Running `DocScanner` instance
    public func dismiss(_ closure: @escaping Dismiss) -> Self {
        dismiss = closure
        return self
    }
}
