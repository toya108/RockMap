import UIKit

class ImageSelactCollectionViewCell: UICollectionViewCell {
    @IBOutlet var uploadButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.uploadButton.layer.cornerRadius = 8
        self.uploadButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.uploadButton.titleLabel?.minimumScaleFactor = 0.1
        self.uploadButton.titleLabel?.numberOfLines = 2
    }
}
