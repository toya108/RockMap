import Auth
import SDWebImage
import UIKit

@IBDesignable
class UserView: UIView {
    @IBOutlet var iconButton: UIButton!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var registeredDateLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromNib()
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

        self.iconButton.clipsToBounds = true
        self.iconButton.layer.cornerRadius = 20
    }

    func configure(
        user: Entity.User,
        registeredDate: Date? = nil,
        parentVc: UIViewController
    ) {
        if user.deleted {
            self.registeredDateLabel.isHidden = true
            self.userNameLabel.text = "退会済みユーザー"
            self.iconButton.setImage(UIImage.AssetsImages.noimage, for: .normal)
            return
        }

        self.userNameLabel.text = user.name

        if let photoURL = user.photoURL {
            self.iconButton.loadImage(url: photoURL)
        } else {
            self.iconButton.setImage(UIImage.AssetsImages.noimage, for: .normal)
        }

        if let registeredDate = registeredDate {
            self.registeredDateLabel.text = "登録日：" + registeredDate.string(dateStyle: .medium)
        } else {
            self.registeredDateLabel.isHidden = true
        }

        self.iconButton.addAction(
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
