import UIKit

class SocialLinkCollectionViewCell: UICollectionViewCell {
    let socialLinkButton = UIButton()
    var socialLink: Entity.User.SocialLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.socialLinkButton.setImage(Resources.Images.Assets.instagram.uiImage, for: .normal)

        self.socialLinkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.socialLinkButton)

        self.socialLinkButton.tintColor = UIColor.Pallete.primaryGreen

        NSLayoutConstraint.activate([
            self.socialLinkButton.heightAnchor.constraint(equalToConstant: 28),
            self.socialLinkButton.widthAnchor.constraint(equalToConstant: 28),
            self.socialLinkButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.socialLinkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.socialLinkButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            self.socialLinkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
    }

    func configure(socialLink: Entity.User.SocialLink) {
        self.socialLink = socialLink
        self.socialLinkButton.setImage(socialLink.linkType.icon.uiImage, for: .normal)
        self.socialLinkButton.isEnabled = !socialLink.link.isEmpty
        self.socialLinkButton.tintColor = socialLink.linkType.color
        self.socialLinkButton.addActionForOnce(
            .init { [weak self] _ in

                guard let self = self else { return }

                self.openLink()
            },
            for: .touchUpInside
        )
    }

    private func openLink() {

        guard let socialLink = socialLink else {
            return
        }

        if case .other = socialLink.linkType {
            guard
                let url = URL(string: socialLink.link)
            else {
                showDisableLinkAlert()
                return
            }

            guard
                UIApplication.shared.canOpenURL(url)
            else {
                showDisableLinkAlert()
                return
            }

            UIApplication.shared.open(url)
        }

        guard
            let url = URL(string: socialLink.linkType.urlBase + socialLink.link)
        else {
            self.showDisableLinkAlert()
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            guard
                let httpsUrl = URL(string: socialLink.linkType.httpsUrlBase + socialLink.link)
            else {
                self.showDisableLinkAlert()
                return
            }

            guard
                UIApplication.shared.canOpenURL(httpsUrl)
            else {
                self.showDisableLinkAlert()
                return
            }

            UIApplication.shared.open(httpsUrl)
        }
    }

    private func showDisableLinkAlert() {
        guard
            let topViewController = self.contentView.root?.getVisibleViewController()
        else {
            return
        }

        topViewController.showOKAlert(
            title: "リンクを開けませんでした",
            message: "無効なリンクの可能性があります。プロフィール編集から入力内容を再度ご確認下さい。"
        )
    }
}
