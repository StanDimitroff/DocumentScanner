//
//  CroppView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 8.12.17.
//

import UIKit

class CroppView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var regionView: UIView!

    private let dragGesture = UIPanGestureRecognizer()

    var onRegionSave: ((CGRect) -> Void)?
    var trackedRegion: CGRect! {
        didSet {
            if !trackedRegion.isEmpty {
                regionView.frame = trackedRegion
            }

            calculateMaskLayer()
        }
    }

    var maskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
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

        regionView?.layer.borderColor = UIColor.white.cgColor
        regionView?.layer.borderWidth = 1

        dragGesture.delegate = self
        addGestureRecognizer(dragGesture)

        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0

        layer.addSublayer(maskLayer)
    }

    func calculateMaskLayer() {
        let outsidePath = UIBezierPath(rect: imageView.bounds)
        let insidePath = UIBezierPath(rect: regionView.frame)

        outsidePath.append(insidePath)

        maskLayer.path = outsidePath.cgPath
        maskLayer.opacity = 0.60
    }

    @IBAction func retake(_ sender: UIBarButtonItem) {
        // return to scanner
        self.removeFromSuperview()
    }

    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        self.removeFromSuperview()

        // TODO: export created region here
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CroppView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
