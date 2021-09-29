import UIKit

class GradeSelectingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var gradeSelectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.gradeSelectButton.layer.cornerRadius = 4

        self.gradeSelectButton.imageView?.contentMode = .scaleAspectFit
        self.gradeSelectButton.contentHorizontalAlignment = .fill
        self.gradeSelectButton.contentVerticalAlignment = .fill
    }

    func configure(grade: Entity.Course.Grade) {
        self.gradeLabel.text = "・" + grade.name
    }
}
