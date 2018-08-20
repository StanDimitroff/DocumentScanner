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
