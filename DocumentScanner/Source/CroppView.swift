//
//  CroppView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 8.12.17.
//

import UIKit

class CroppView: UIView {

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

    var onRetake: (() -> Void)?
    var onRegionSave: ((ObservationRectangle) -> Void)?

    var observationRect: ObservationRectangle = .zero {
        didSet {
            setInitialRegion()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
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
        keepButton.title   = NSLocalizedString("Crop", comment: "Crop")

        [topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner].forEach {
            corner in

            let dragGesture = UIPanGestureRecognizer()
            dragGesture.addTarget(self, action: #selector(resizeRegion(_:)))
            dragGesture.delegate = self

            corner.addGestureRecognizer(dragGesture)

            addSubview(corner)
        }

        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0

        imageView.layer.addSublayer(maskLayer)

        Utils.subscribeToDeviceOrientationNotifications(self, selector: #selector(deviceOrientationDidChange(_:)))
    }

    private func setInitialRegion() {
        if observationRect.isEmpty {
            let width = imageView.frame.size.width
            let height = imageView.frame.size.height
            
            observationRect = ObservationRectangle(
                topLeft: CGPoint(x: width / 3.0, y: height / 3.0),
                topRight: CGPoint(x: 2.0 * width / 3.0, y: height / 3.0),
                bottomRight: CGPoint(x: 2.0 * width / 3.0, y: 2.0 * height / 3.0),
                bottomLeft: CGPoint(x: width / 3.0, y: 2.0 * height / 3.0)
            )
        }

        drawPath()
        setInitialCorners()
    }

    private func setInitialCorners() {
        topLeftCorner.center     = observationRect.topLeft
        topRightCorner.center    = observationRect.topRight

        bottomRightCorner.center = observationRect.bottomRight
        bottomLeftCorner.center  = observationRect.bottomLeft
    }

    private func updateShapeLayer() {
        shapeLayer.path        = regionPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor   = UIColor.clear.cgColor
        shapeLayer.lineWidth   = 1

        imageView.layer.addSublayer(shapeLayer)
    }

    private func updateMaskLayer() {
        let outsidePath = UIBezierPath(rect: imageView.bounds)

        outsidePath.append(regionPath)

        maskLayer.path = outsidePath.cgPath
        maskLayer.opacity = 0.40
    }

    @objc private func resizeRegion(_ gesture: UIPanGestureRecognizer) {
        let currentPoint = gesture.location(in: imageView)
        guard let cornerView   = gesture.view as? CornerView else { return }

        cornerView.center = currentPoint

        switch cornerView.position {
        case .topLeft: observationRect.topLeft         = currentPoint
        case .topRight: observationRect.topRight       = currentPoint
        case .bottomRight: observationRect.bottomRight = currentPoint
        case .bottomLeft: observationRect.bottomLeft   = currentPoint
        }
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
        self.removeFromSuperview()

        onRegionSave?(observationRect)
    }

    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        if let superView = self.superview {
            self.frame.size = superView.frame.size
        }
    }

    deinit {
        Utils.unsubscribeFromOrientationNotifications(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CroppView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
