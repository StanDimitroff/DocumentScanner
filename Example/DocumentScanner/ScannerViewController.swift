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

        if #available(iOS 11.0, *) {
            self.previewView = PreviewView(frame: self.view.frame)

            let scanner = DocScanner(presenter: self)
                .startSession()
                // this automatically stops scanner session
                .exportImage { [weak self] image in
                    guard let `self` = self else { return }

                    self.previewView.imageView.image = image
                    self.view.addSubview(self.previewView)
                }
                .dismiss { [weak self] in
                    guard let `self` = self else { return }
                    self.dismiss(animated: true, completion: nil)
                }


            self.previewView.onRescan = {
                // continue session on current scanner instance
                scanner.continueSession()
            }
        } else {
            print("DocumentScanner not available before iOS 11")
        }
    }
}
