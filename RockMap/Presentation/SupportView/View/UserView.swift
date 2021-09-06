
import Auth
import UIKit
import SDWebImage

@IBDesignable
class UserView: UIView {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var registeredDateLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    private func loadFromNib() {
        let view = UINib(
            nibName: UserView.className,
            bundle: Bundle(for: type(of: self))
        ).instantiate(withOwner: self).first as! UIView

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        iconButton.clipsToBounds = true
        iconButton.layer.cornerRadius = 20
    }

    func configure(
        user: Entity.User,
        registeredDate: Date? = nil,
        parentVc: UIViewController
    ) {
        if user.deleted {
            registeredDateLabel.isHidden = true
            userNameLabel.text = "退会済みユーザー"
            iconButton.setImage(UIImage.AssetsImages.noimage, for: .normal)
            return
        }

        userNameLabel.text = user.name

        if let photoURL = user.photoURL {
            iconButton.loadImage(url: photoURL)
        } else {
            iconButton.setImage(UIImage.AssetsImages.noimage, for: .normal)
        }

        if let registeredDate = registeredDate {
            registeredDateLabel.text = "登録日：" + registeredDate.string(dateStyle: .medium)
        } else {
            registeredDateLabel.isHidden = true
        }

        iconButton.addAction(
            .init { _ in
                if AuthManager.shared.uid == user.id {
                    guard
                        let index = ScreenType.allCases.firstIndex(of: .myPage)
                    else {
                        return
                    }
                    parentVc.tabBarController?.selectedIndex = index

                } else {
                    let vc = MyPageViewController.createInstance(
                        viewModel: .init(userKind: .other(user: user))
                    )
                    parentVc.navigationController?.pushViewController(vc, animated: true)
                }
            },
            for: .touchUpInside
        )
    }


}
