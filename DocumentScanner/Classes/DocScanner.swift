//
//  DocScanner.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import UIKit
import AVFoundation

public final class DocScanner {

    public var presenter: UIViewController!

    private var camera: Camera
    private let rectDetector = RectangleDetector()

    public var onImageExport: ((UIImage) -> Void)?

    public init() {
        camera = Camera(rectDetector)
    }

    public func exportImage() {

    }

    public func startSession() {
        camera.prepareForSession {
            cameraLayer, scannerView in

            cameraLayer.frame = presenter.view.bounds
            scannerView.frame = presenter.view.frame
            presenter.view.addSubview(scannerView)
        }
        
        camera.startSession()
    }
}


