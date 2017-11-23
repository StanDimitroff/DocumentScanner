//
//  PreviewView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 21.11.17.
//

import UIKit

final class PreviewView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    func setup() {
        let podBundle = Bundle(for: self.classForCoder)

        if let bundleURL = podBundle.url(forResource: "DocumentScanner", withExtension: "bundle") {
            if let bundle = Bundle.init(url: bundleURL) {

                let nib  = UINib(nibName: "PreviewView", bundle: bundle)
                let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

                view.frame = bounds

                addSubview(view)
            } else {
                assertionFailure("Could not load the bundle")
            }
        } else {
            assertionFailure("Could not create a path to the bundle")
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {

    }

    @IBAction func retake(_ sender: UIBarButtonItem) {
        
    }

}
