//
//  CornerView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 13.12.17.
//

import UIKit

class CornerView: UIView {

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = self.bounds.width / 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
}
