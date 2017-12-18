//
//  ViewController.swift
//  DocumentScanner
//
//  Created by StanDimitroff on 11/20/2017.
//  Copyright (c) 2017 StanDimitroff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func scanDocument(_ sender: UIButton) {
        let scannerVC = ScannerViewController()

        present(scannerVC, animated: true, completion: nil)
    }
}

