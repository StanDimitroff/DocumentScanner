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

    override func viewDidLoad() {
        super.viewDidLoad()

        scanner.presenter = self
        scanner.startSession()
    }
}

