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

    @IBOutlet weak var scannerView: ScannerView!

    let scanner = DocScanner()

    override func viewDidLoad() {
        super.viewDidLoad()

        scanner.scannerView = scannerView
        scanner.startSession()
    }
}

