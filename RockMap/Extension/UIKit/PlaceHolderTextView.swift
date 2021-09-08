import UIKit

@IBDesignable class PlaceHolderTextView: UITextView {
    // MARK: Stored Instance Properties

    @IBInspectable var placeHolder: String = "" {
        willSet {
            self.placeHolderLabel.text = newValue
            self.placeHolderLabel.sizeToFit()
        }
    }

    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5.0, y: 8.0, width: 0.0, height: 0.0))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
        label.backgroundColor = .clear
        self.addSubview(label)
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.changeVisiblePlaceHolder()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textChanged),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }

    func updatePlaceholder(_ placeholder: String) {
        self.placeHolder = placeholder
        self.changeVisiblePlaceHolder()
    }

    private func changeVisiblePlaceHolder() {
        self.placeHolderLabel.alpha = (self.placeHolder.isEmpty || !self.text.isEmpty) ? 0.0 : 1.0
    }

    @objc private func textChanged(notification: NSNotification?) {
        self.changeVisiblePlaceHolder()
    }
}
