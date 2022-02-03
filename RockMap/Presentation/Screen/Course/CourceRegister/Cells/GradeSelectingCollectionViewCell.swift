import UIKit

class GradeSelectingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var gradeSelectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        var configuration = UIButton.Configuration.plain()
        configuration.image = Resources.Images.System.arrowUpLeftSquare.uiImage
        configuration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        gradeSelectButton.configuration = configuration
    }

    func configure(grade: Entity.Course.Grade) {
        self.gradeLabel.text = "・" + grade.name
    }
}
