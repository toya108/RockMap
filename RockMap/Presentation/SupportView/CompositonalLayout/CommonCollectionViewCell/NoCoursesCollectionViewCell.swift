import UIKit

class NoCoursesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addCourseButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 8
        self.addCourseButton.layer.cornerRadius = 8
    }
}
