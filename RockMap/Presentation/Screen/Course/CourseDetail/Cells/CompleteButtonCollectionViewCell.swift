import UIKit

class CompleteButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet var completeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.completeButton.layer.cornerRadius = 8
    }
}
