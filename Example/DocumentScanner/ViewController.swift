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

    var previewView: PreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool { return true }

    @IBAction func scanDocument(_ sender: UIButton) {
        let scanner = DocScanner()
        scanner.presenter = self
        scanner.startSession()

        scanner.onImageExport = { [weak self]
            
            image in

            guard let `self` = self else { return }
            
            self.previewView = PreviewView(frame: self.view.frame)
            self.previewView.imageView.image = image
            
            self.view.addSubview(self.previewView)
        }
    }
}

