//
//  ViewController.swift
//  DocumentScanner
//
//  Created by StanDimitroff on 11/20/2017.
//  Copyright (c) 2017 StanDimitroff. All rights reserved.
//

import UIKit
import DocumentScanner

class ViewController: UIViewController {

    let scanner = DocScanner()
    var previewView: PreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool { return true }

    @IBAction func scanDocument(_ sender: UIButton) {
        scanner.presenter = self
        scanner.startSession()

        observeScannerOutput()
    }

    func observeScannerOutput() {
        scanner.onImageExport = {

            image in

            self.previewView = PreviewView(frame: self.view.frame)
            self.previewView.imageView.image = image

            self.view.addSubview(self.previewView)
        }
    }
}

