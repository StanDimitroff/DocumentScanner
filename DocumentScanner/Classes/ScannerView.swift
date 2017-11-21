//
//  ScannerView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation

public class ScannerView: UIView {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var trackView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var onImageCapture: (() -> Void)?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
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

        trackView?.layer.borderColor = UIColor.red.cgColor
        trackView?.layer.borderWidth = 4
        trackView?.backgroundColor   = .clear
    }

    @IBAction func captureImage(_ sender: UIButton) {
        onImageCapture?()
    }
}
