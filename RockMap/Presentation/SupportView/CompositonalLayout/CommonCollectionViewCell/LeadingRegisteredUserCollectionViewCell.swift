import UIKit

class LeadingRegisteredUserCollectionViewCell: UICollectionViewCell {
    @IBOutlet var userView: UserView!

    func configure(
        user: Entity.User,
        registeredDate: Date? = nil,
        parentVc: UIViewController
    ) {
        self.userView.configure(
            user: user,
            registeredDate: registeredDate,
            parentVc: parentVc
        )
    }
}
