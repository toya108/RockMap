import UIKit

class ClimbRecordTableViewCell: UITableViewCell {
    @IBOutlet var userView: UserView!
    @IBOutlet var climbedTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(
        user: Entity.User,
        climbedDate: Date,
        type: Entity.ClimbRecord.ClimbedRecordType,
        parentVc: UIViewController
    ) {
        self.userView.configure(
            user: user,
            registeredDate: climbedDate,
            parentVc: parentVc
        )

        self.climbedTypeLabel.text = type.name
        self.climbedTypeLabel.textColor = type.color
    }
}

private extension Entity.ClimbRecord.ClimbedRecordType {
    var color: UIColor {
        switch self {
        case .flash:
            return UIColor.Pallete.primaryGreen

        case .redPoint:
            return UIColor.Pallete.primaryPink
        }
    }
}
