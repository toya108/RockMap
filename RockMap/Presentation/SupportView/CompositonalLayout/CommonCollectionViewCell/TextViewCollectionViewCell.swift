import UIKit

class TextViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet var textView: PlaceHolderTextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configurePlaceholder(_ placeholder: String) {
        self.textView.updatePlaceholder(placeholder)
    }
}
