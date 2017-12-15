//
//  TrackView.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 14.12.17.
//

import UIKit

class TrackView: UIView {

    private let borderLayer = CAShapeLayer()

    init() {
        super.init(frame: CGRect(x: 100, y: 100, width: 300, height: 300))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        borderLayer.fillColor   = UIColor(red: 0.243, green: 0.156, blue: 0.018, alpha: 0.3).cgColor
        borderLayer.strokeColor = UIColor.orange.cgColor
        borderLayer.lineWidth   = 1

        layer.addSublayer(borderLayer)
    }

    func updateBorderLayer(withPath path: UIBezierPath) {
        borderLayer.path = path.cgPath

        let frame = convert(self.bounds, from: self.superview!)
        borderLayer.frame = frame
    }
}
