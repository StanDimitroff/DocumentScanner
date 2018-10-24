import UIKit

open class CroppView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var retakeButton: UIBarButtonItem!
    @IBOutlet weak var keepButton: UIBarButtonItem!

    private let topLeftCorner     = CornerView(position: .topLeft)
    private let topRightCorner    = CornerView(position: .topRight)

    private let bottomRightCorner = CornerView(position: .bottomRight)
    private let bottomLeftCorner  = CornerView(position: .bottomLeft)

    private let shapeLayer = CAShapeLayer()
    private let maskLayer  = CAShapeLayer()

    private var regionPath = UIBezierPath()

    private var imageViewFrame: CGRect {
        return imageView.contentClippingRect
    }

    var onRetake: (() -> Void)?
    var onRegionSave: ((ObservationRectangle) -> Void)?

    var image: UIImage? {
        didSet {
            imageView.image = image
            updateContentMode()
        }
    }

    var observationRect: ObservationRectangle = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        var bundle: Bundle? = nil

        let libBundle = Bundle(for: self.classForCoder)

        // Search resource in Pod resource bundle
        if let bundleURL = libBundle.url(forResource: "DocumentScanner", withExtension: "bundle") {
            if let resourceBundle = Bundle.init(url: bundleURL) {
                bundle = resourceBundle
            } else {
                assertionFailure("Could not load the resource bundle")
            }
        } else {
            bundle = libBundle
        }

        let nib  = UINib(nibName: "CroppView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        view.frame = bounds

        addSubview(view)

        retakeButton.title = NSLocalizedString("Retake", comment: "Retake")
        keepButton.title   = NSLocalizedString("Keep Scan", comment: "Keep Scan")

        [topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner].forEach {
            corner in

            let dragGesture = UIPanGestureRecognizer()
            dragGesture.addTarget(self, action: #selector(resizeRegion(_:)))
            dragGesture.delegate = self

            corner.addGestureRecognizer(dragGesture)

            addSubview(corner)
        }

        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0

        updateImageSize(with: self.frame.size)
        
        imageView.layer.addSublayer(shapeLayer)
        imageView.layer.addSublayer(maskLayer)

        Utils.subscribeToDeviceOrientationNotifications(self, selector: #selector(deviceOrientationDidChange))
    }

    private func setInitialRegion() {
        let width = imageViewFrame.size.width
        let height = imageViewFrame.size.height

        observationRect = ObservationRectangle(
            topLeft: CGPoint(x: imageViewFrame.center.x - width / 3, y: imageViewFrame.center.y - height / 3),
            topRight: CGPoint(x: imageViewFrame.center.x + width / 3, y: imageViewFrame.center.y - height / 3),
            bottomRight: CGPoint(x: imageViewFrame.center.x + width / 3, y: imageViewFrame.center.y + height / 3),
            bottomLeft: CGPoint(x: imageViewFrame.center.x - width / 3, y: imageViewFrame.center.y + height / 3)
        )

        drawPath()
        updateCorners()
    }

    private func updateRegionOrientation() {
        let width = imageViewFrame.size.width
        let height = imageViewFrame.size.height

        observationRect = ObservationRectangle(
            topLeft: CGPoint(x: imageViewFrame.center.x - width / 3, y: imageViewFrame.center.y - height / 3),
            topRight: CGPoint(x: imageViewFrame.center.x + width / 3, y: imageViewFrame.center.y - height / 3),
            bottomRight: CGPoint(x: imageViewFrame.center.x + width / 3, y: imageViewFrame.center.y + height / 3),
            bottomLeft: CGPoint(x: imageViewFrame.center.x - width / 3, y: imageViewFrame.center.y + height / 3)
        )

        drawPath()
        updateCorners()
    }

    private func updateContentMode() {
        guard let image = self.image else { return }
        imageView.contentMode = Utils.contentModeFromInterfaceOrientation(for: image)
    }

    private func updateCorners() {
        topLeftCorner.center     = observationRect.topLeft
        topRightCorner.center    = observationRect.topRight

        bottomRightCorner.center = observationRect.bottomRight
        bottomLeftCorner.center  = observationRect.bottomLeft
    }

    private func updateShapeLayer() {
        shapeLayer.path        = regionPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor   = UIColor.clear.cgColor
        shapeLayer.lineWidth   = 1.5
    }

    private func updateMaskLayer() {
        let outsidePath = UIBezierPath(rect: imageView.bounds)

        outsidePath.append(regionPath)

        maskLayer.path = outsidePath.cgPath
        maskLayer.opacity = 0.40
    }

    @objc private func resizeRegion(_ gesture: UIPanGestureRecognizer) {
        var currentPoint = gesture.location(in: imageView)
        guard let cornerView = gesture.view as? CornerView else { return }

        let leftBound   = imageViewFrame.origin.x
        let rightBound  = imageViewFrame.maxX
        let topBound    = imageViewFrame.origin.y
        let bottomBound = imageViewFrame.maxY

        // avoid drawing beyond the bounds
        if currentPoint.x < leftBound { currentPoint.x = leftBound }
        if currentPoint.x > rightBound { currentPoint.x = rightBound }
        if currentPoint.y < topBound { currentPoint.y = topBound }
        if currentPoint.y > bottomBound { currentPoint.y = bottomBound }

        cornerView.center = currentPoint

        switch cornerView.position {
        case .topLeft: observationRect.topLeft         = currentPoint
        case .topRight: observationRect.topRight       = currentPoint
        case .bottomRight: observationRect.bottomRight = currentPoint
        case .bottomLeft: observationRect.bottomLeft   = currentPoint
        }

        drawPath()
        updateCorners()
    }

    private func drawPath() {
        regionPath.removeAllPoints()

        // draw according to clockwise
        regionPath.move(to: observationRect.topLeft)
        regionPath.addLine(to: observationRect.topRight)
        regionPath.addLine(to: observationRect.bottomRight)
        regionPath.addLine(to: observationRect.bottomLeft)

        regionPath.close()

        updateShapeLayer()
        updateMaskLayer()
    }

    @IBAction func retake(_ sender: UIBarButtonItem) {
        // return to scanner
        self.removeFromSuperview()

        onRetake?()
    }

    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        // save region to crop
        onRegionSave?(observationRect)

        self.removeFromSuperview()
    }

    @objc private func deviceOrientationDidChange() {
        if let superView = self.superview {
            let newSize = superView.frame.size
            self.frame.size = newSize

            // update imageView contentMode first
            updateContentMode()
            updateImageSize(with: newSize)

            updateRegionOrientation()
        }
    }

    private func updateImageSize(with size: CGSize) {
        self.imageView.frame.size = CGSize(width: size.width, height: size.height - 44)
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        setInitialRegion()

        updateShapeLayer()
        updateMaskLayer()
    }

    deinit {
        Utils.unsubscribeFromOrientationNotifications(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CroppView: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
