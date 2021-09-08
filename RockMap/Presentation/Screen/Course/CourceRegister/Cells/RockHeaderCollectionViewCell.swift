import UIKit

class RockHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var rockImageView: UIImageView!
    @IBOutlet var rockNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 8
    }

    func configure(rockName: String, headerUrl: URL?) {
        self.rockImageView.loadImage(url: headerUrl)
        self.rockNameLabel.text = rockName
    }
}
