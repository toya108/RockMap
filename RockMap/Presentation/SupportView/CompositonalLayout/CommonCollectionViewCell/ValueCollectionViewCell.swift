import UIKit

class ValueCollectionViewCell: UICollectionViewCell {
    struct ValueCellStructure: Hashable {
        let image: UIImage
        let title: String
        let subTitle: String
    }

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!

    func configure(_ data: ValueCellStructure) {
        self.iconImageView.image = data.image
        self.titleLabel.text = data.title
        self.subTitleLabel.text = data.subTitle
    }
}
