//
//  SocialLinkCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

class SocialLinkCollectionViewCell: UICollectionViewCell {

    let socialLinkButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        socialLinkButton.setImage(UIImage.AssetsImages.instagram, for: .normal)

        socialLinkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(socialLinkButton)

        NSLayoutConstraint.activate([
            socialLinkButton.heightAnchor.constraint(equalToConstant: 28),
            socialLinkButton.widthAnchor.constraint(equalToConstant: 28),
            socialLinkButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            socialLinkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            socialLinkButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            socialLinkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
    }

    func configure(for type: FIDocument.User.SocialLinkType) {
        socialLinkButton.setImage(type.icon, for: .normal)
    }
}
