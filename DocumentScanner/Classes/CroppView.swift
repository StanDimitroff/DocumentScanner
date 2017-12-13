//
//  CroppView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 8.12.17.
//

import UIKit

class CroppView: UIView {

    struct Position {
        var leftUp: CGPoint      = .zero
        var leftBottom: CGPoint  = .zero
        var rigntUp: CGPoint     = .zero
        var rightBottom: CGPoint = .zero
    }

    @IBOutlet weak var imageView: UIImageView!

    private let regionView = RegionView()

    private let leftUpCorner      = CornerView()
    private let rightUpCorner     = CornerView()

    private let leftBottomCorner  = CornerView()
    private let rightBottomCorner = CornerView()

    private let maskLayer = CAShapeLayer()

    private var regionPath = UIBezierPath()
    private var position   = Position()

    var onRetake: (() -> Void)?
    var onRegionSave: ((UIBezierPath) -> Void)?

    var trackedRegion: CGRect = .zero {
        didSet {
            if !trackedRegion.isEmpty {
                regionView.frame = trackedRegion
                regionPath = UIBezierPath(rect: trackedRegion)
                position = Position(
                    leftUp: trackedRegion.origin,
                    leftBottom: CGPoint(x: trackedRegion.origin.x, y: trackedRegion.maxY),
                    rigntUp: CGPoint(x: trackedRegion.maxX, y: trackedRegion.origin.y),
                    rightBottom: CGPoint(x: trackedRegion.maxX, y: trackedRegion.maxY))

                regionView.updateBorderLayer(withPath: regionPath)
                updateMaskLayer()
                setInitialCorners()
            }
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
        let podBundle = Bundle(for: self.classForCoder)

        if let bundleURL = podBundle.url(forResource: "DocumentScanner", withExtension: "bundle") {
            if let bundle = Bundle.init(url: bundleURL) {

                let nib  = UINib(nibName: "CroppView", bundle: bundle)
                let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

                view.frame = bounds

                addSubview(view)
            } else {
                assertionFailure("Could not load the bundle")
            }
        } else {
            assertionFailure("Could not create a path to the bundle")
        }

        addSubview(regionView)

        [leftUpCorner, rightUpCorner, leftBottomCorner, rightBottomCorner].forEach {
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
    }

    private func setInitialCorners() {
        leftUpCorner.center = trackedRegion.origin
        rightUpCorner.center = CGPoint(x: trackedRegion.maxX, y: trackedRegion.origin.y)

        leftBottomCorner.center = CGPoint(x: trackedRegion.origin.x, y: trackedRegion.maxY)
        rightBottomCorner.center = CGPoint(x: trackedRegion.maxX, y: trackedRegion.maxY)
    }

    private func updateMaskLayer() {
        let outsidePath = UIBezierPath(rect: imageView.bounds)

        outsidePath.append(regionPath)

        maskLayer.path = outsidePath.cgPath
        maskLayer.opacity = 0.50
    }

    @objc private func resizeRegion(_ gesture: UIPanGestureRecognizer) {
        regionPath.removeAllPoints()

        let currentPoint = gesture.location(in: imageView)
        let cornerView   = gesture.view
        cornerView?.center = currentPoint

        regionPath.move(to: currentPoint)

        if cornerView == leftUpCorner {
            regionPath.addLine(to: position.rigntUp)
            regionPath.addLine(to: position.rightBottom)
            regionPath.addLine(to: position.leftBottom)

            position.leftUp = currentPoint

        } else if cornerView == leftBottomCorner {
            regionPath.addLine(to: position.leftUp)
            regionPath.addLine(to: position.rigntUp)
            regionPath.addLine(to: position.rightBottom)

            position.leftBottom = currentPoint
        } else if cornerView == rightUpCorner {
            regionPath.addLine(to: position.rightBottom)
            regionPath.addLine(to: position.leftBottom)
            regionPath.addLine(to: position.leftUp)

            position.rigntUp = currentPoint

        } else if cornerView == rightBottomCorner {
            regionPath.addLine(to: position.leftBottom)
            regionPath.addLine(to: position.leftUp)
            regionPath.addLine(to: position.rigntUp)

            position.rightBottom = currentPoint
        }

        regionPath.close()

        regionView.updateBorderLayer(withPath: regionPath)
        updateMaskLayer()
    }

    @IBAction func retake(_ sender: UIBarButtonItem) {
        // return to scanner
        self.removeFromSuperview()
        onRetake?()
    }

    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        //self.removeFromSuperview()

        // TODO: export created region here
        //let rect = regionPath.cgPath.boundingBoxOfPath
        onRegionSave?(regionPath)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CroppView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
