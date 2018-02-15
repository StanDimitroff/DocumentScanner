//
//  ScannerView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit

final class ScannerView: UIView {

    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    private let shapeLayer = CAShapeLayer()
    private var regionPath = UIBezierPath()

    var observationRect = ObservationRectangle.zero {
        didSet {
            resizeRegion()
        }
    }

    var onImageCapture: (() -> Void)?
    var onDismiss: (() -> Void)?

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

                let nib  = UINib(nibName: "ScannerView", bundle: bundle)
                let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

                view.frame = bounds

                addSubview(view)
            } else {
                assertionFailure("Could not load the bundle")
            }
        } else {
            assertionFailure("Could not create a path to the bundle")
        }

        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
    }

    func updateShapeLayer() {
        shapeLayer.path        = regionPath.cgPath
        shapeLayer.strokeColor = UIColor.orange.cgColor
        shapeLayer.fillColor   = UIColor(red: 0.95, green: 0.61, blue: 0.07, alpha: 1.0).cgColor
        shapeLayer.opacity     = 0.38
        shapeLayer.lineWidth   = 1

        self.layer.addSublayer(shapeLayer)
    }

    private func resizeRegion() {
        regionPath.removeAllPoints()

        // draw according to clockwise
        regionPath.move(to: observationRect.topLeft)
        regionPath.addLine(to: observationRect.topRight)
        regionPath.addLine(to: observationRect.bottomRight)
        regionPath.addLine(to: observationRect.bottomLeft)

        regionPath.close()

        updateShapeLayer()
    }


    @IBAction func captureImage(_ sender: UIButton) {
        onImageCapture?()
    }

    @IBAction func dismiss(_ sender: UIButton) {
        onDismiss?()
    }
}
