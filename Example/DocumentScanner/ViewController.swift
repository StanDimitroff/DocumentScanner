import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    @IBAction func scanDocument(_ sender: UIButton) {
        let scannerVC = ScannerViewController()

        present(scannerVC, animated: true, completion: nil)
    }
}
