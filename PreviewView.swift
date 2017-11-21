//
//  PreviewView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 21.11.17.
//

import UIKit

class PreviewView: UIView {

    var imageView = UIImageView()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
