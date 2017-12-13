//
//  RegionView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 11.12.17.
//

import UIKit

class RegionView: UIView {

    private let borderLayer = CAShapeLayer()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth   = 1

        layer.addSublayer(borderLayer)
    }

    func updateBorderLayer(withPath path: UIBezierPath) {
        borderLayer.path = path.cgPath

        let frame = convert(self.bounds, from: self.superview!)
        borderLayer.frame = frame
    }
}
