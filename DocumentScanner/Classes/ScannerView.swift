//
//  ScannerView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit

final class ScannerView: UIView {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var trackView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

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

        trackView?.layer.borderColor = UIColor.orange.cgColor
        trackView?.layer.borderWidth = 1
        trackView?.isHidden = true

        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
    }

    @IBAction func captureImage(_ sender: UIButton) {
        onImageCapture?()
    }

    @IBAction func dismiss(_ sender: UIButton) {
        onDismiss?()
    }
}
