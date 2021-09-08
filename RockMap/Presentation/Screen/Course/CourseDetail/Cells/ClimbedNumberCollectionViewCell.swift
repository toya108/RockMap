import UIKit

class ClimbedNumberCollectionViewCell: UICollectionViewCell {
    @IBOutlet var totalNumberLabel: UILabel!
    @IBOutlet var totalFlashLabel: UILabel!
    @IBOutlet var totalRedPointLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 8
    }

    func configure(
        total: Int,
        flash: Int,
        redPoint: Int
    ) {
        self.totalNumberLabel.text = total.description
        self.totalFlashLabel.text = flash.description
        self.totalRedPointLabel.text = redPoint.description
    }
}
