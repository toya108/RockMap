import Combine
import UIKit

class CourseCollectionViewCell: UICollectionViewCell {
    @IBOutlet var courseNameLabel: UILabel!
    @IBOutlet var courseImageView: UIImageView!
    @IBOutlet var userView: UserView!

    private var bindings = Set<AnyCancellable>()
    private let fetchUserUsecase = Usecase.User.FetchById()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.cornerRadius = 20
        contentView.layer.cornerRadius = 20
    }

    func configure(
        course: Entity.Course,
        parentVc: UIViewController
    ) {
        self.courseNameLabel.text = course.name + course.grade.name
        self.courseImageView.loadImage(url: course.headerUrl)

        self.fetchUserUsecase.fetchUser(by: course.registeredUserId)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .compactMap { $0 }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.userView.configure(
                    user: user,
                    registeredDate: course.createdAt,
                    parentVc: parentVc
                )
            }
            .store(in: &self.bindings)
    }
}
