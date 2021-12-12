import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var thirdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.mainImageView.layer.cornerRadius = 8
        self.iconImageView.tintColor = .label
    }

    func configure(
        imageUrl: URL?,
        iconImage: UIImage? = nil,
        title: String,
        first: String?,
        second: String?,
        third: String?
    ) {
        self.mainImageView.loadImage(url: imageUrl)
        self.titleLabel.text = title

        if let iconImage = iconImage {
            self.iconImageView.image = iconImage
            self.iconImageView.isHidden = false
        } else {
            self.iconImageView.isHidden = true
        }

        if let first = first {
            self.firstLabel.text = first
        } else {
            self.firstLabel.isHidden = true
        }

        if let second = second {
            self.secondLabel.text = second
        } else {
            self.secondLabel.isHidden = true
        }

        if let third = third {
            self.thirdLabel.text = third
        } else {
            self.thirdLabel.isHidden = true
        }
    }
}
