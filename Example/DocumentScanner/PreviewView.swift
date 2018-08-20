import UIKit

final class PreviewView: UIView {

    @IBOutlet weak var imageView: UIImageView!

    var onRescan: (() -> Void)?

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    private func setup() {

        let bundle = Bundle(for: type(of: self))
        let nib    = UINib(nibName: "PreviewView", bundle: bundle)
        let view   = nib.instantiate(withOwner: self, options: nil).first as! UIView

        view.frame = bounds

        addSubview(view)
    }

    @IBAction func retake(_ sender: UIBarButtonItem) {
        self.removeFromSuperview()
        onRescan?()
    }
}
