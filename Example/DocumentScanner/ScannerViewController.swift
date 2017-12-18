//
//  ScannerViewController.swift
//  DocumentScanner_Example
//
//  Created by Stanislav Dimitrov on 18.12.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import DocumentScanner

class ScannerViewController: UIViewController {

    var previewView: PreviewView!

    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scanner = DocScanner(presenter: self)
        scanner.startSession()

        // this automatically stops scanner session
        scanner.onImageExport = { [weak self]

            image in

            guard let `self` = self else { return }

            self.previewView = PreviewView(frame: self.view.frame)
            self.previewView.imageView.image = image

            self.previewView.onRescan = {
                // continue session on current scanner instance
                scanner.continueSession()
            }

            self.view.addSubview(self.previewView)
        }

        scanner.onDismiss = { [weak self] in

            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
