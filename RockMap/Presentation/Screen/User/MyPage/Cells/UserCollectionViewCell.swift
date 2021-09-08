import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var userView: UserView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.editProfileButton.layer.cornerRadius = 8
    }
}
