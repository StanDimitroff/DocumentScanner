import UIKit

open class ScannerView: UIView {

    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var menuViewHeight: NSLayoutConstraint!

    private let shapeLayer = CAShapeLayer()
    private var regionPath = UIBezierPath()

    var observationRect = ObservationRectangle.zero {
        didSet {
            resizeRegion()
        }
    }

    var onImageCapture: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onSave: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        var bundle: Bundle?

        let libBundle = Bundle(for: self.classForCoder)

        // Search resource in Pod resource bundle
        if let bundleURL = libBundle.url(forResource: "DocumentScanner", withExtension: "bundle") {
            if let resourceBundle = Bundle.init(url: bundleURL) {
                bundle = resourceBundle
            } else {
                assertionFailure("Could not load the resource bundle")
            }
        } else {
            bundle = libBundle
        }

        let nib  = UINib(nibName: "ScannerView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
          return
        }

        view.frame = bounds

        addSubview(view)

        self.layer.addSublayer(shapeLayer)

        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: "Save"), for: .normal)
        saveButton.layer.cornerRadius = 12

        Utils.subscribeToDeviceOrientationNotifications(self, selector: #selector(deviceOrientationDidChange))

        menuViewHeight.constant = self.safeAreaInsets.top
    }

    @objc private func deviceOrientationDidChange() {
        menuViewHeight.constant = self.safeAreaInsets.top
    }

    func updateShapeLayer() {
        shapeLayer.path        = regionPath.cgPath
        shapeLayer.strokeColor = UIColor.orange.cgColor
        shapeLayer.fillColor   = UIColor(red: 0.95, green: 0.61, blue: 0.07, alpha: 1.0).cgColor
        shapeLayer.opacity     = 0.38
        shapeLayer.lineWidth   = 1
    }

    private func resizeRegion() {
        regionPath.removeAllPoints()

        // draw according to clockwise
        regionPath.move(to: observationRect.topLeft)
        regionPath.addLine(to: observationRect.topRight)
        regionPath.addLine(to: observationRect.bottomRight)
        regionPath.addLine(to: observationRect.bottomLeft)

        regionPath.close()

        updateShapeLayer()
    }

    @IBAction func captureImage(_ sender: UIButton) {
        onImageCapture?()
    }

    @IBAction func save(_ sender: UIButton) {
        onSave?()
    }

    @IBAction func dismiss(_ sender: UIButton) {
        onDismiss?()
    }
}
