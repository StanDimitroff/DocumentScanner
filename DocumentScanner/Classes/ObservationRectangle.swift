//
//  ObservationRectangle.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 14.02.18.
//

import UIKit

struct ObservationRectangle {
    var topLeft: CGPoint     = .zero
    var topRight: CGPoint    = .zero
    var bottomRight: CGPoint = .zero
    var bottomLeft: CGPoint  = .zero

    static var zero: ObservationRectangle {
        return .init()
    }

    var isEmpty: Bool {
        return topLeft     == .zero &&
               topRight    == .zero &&
               bottomRight == .zero &&
               bottomLeft  == .zero
    }
}
