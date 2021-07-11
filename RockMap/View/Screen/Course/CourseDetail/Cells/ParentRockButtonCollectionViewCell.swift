//
//  ParentRockButtonCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/23.
//

import UIKit

class ParentRockButtonCollectionViewCell: UICollectionViewCell {

    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let rockButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        contentView.addSubview(stackView)
        NSLayoutConstraint.build {
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        }

        iconImageView.tintColor = .black
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage.AssetsImages.rockFill
        stackView.addArrangedSubview(iconImageView)
        NSLayoutConstraint.build {
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
            iconImageView.widthAnchor.constraint(equalToConstant: 36)
        }

        rockButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        rockButton.setTitleColor(.black, for: .normal)
        stackView.addArrangedSubview(rockButton)
    }

    func configure(
        title: String,
        didTap: @escaping () -> Void
    ) {
        rockButton.setTitle(title, for: .normal)
        rockButton.addAction(
            .init { _ in didTap() },
            for: .touchUpInside
        )
    }
}
