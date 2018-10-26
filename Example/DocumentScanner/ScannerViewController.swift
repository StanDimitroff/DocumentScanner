import UIKit
import DocumentScanner

class ScannerViewController: UIViewController {

    var previewView: PreviewView!

    override var prefersStatusBarHidden: Bool { return true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.previewView = PreviewView(frame: self.view.frame)

            let scanner = DocScanner(presenter: self)
                // can be executed muliple times across app logic
                .config {
                    $0.minimumConfidence = 0.6
                    $0.minimumSize = 0.3
                    $0.quadratureTolerance = 45
                    $0.exportMultiple = true
                }
                .startSession()
                // this automatically stops scanner session
                .exportImage { [weak self] image in
                    guard let `self` = self else { return }
                    self.previewView.imageView.image = image

                    self.view.addSubview(self.previewView)
                }
                .exportImages { [weak self] images in
                    guard let `self` = self else { return }
                    self.previewView.imageView.image = images[0]
                    self.view.addSubview(self.previewView)
                  
                    print("Exported images: \(images.count)")
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewView.frame.size = size
    }
}
