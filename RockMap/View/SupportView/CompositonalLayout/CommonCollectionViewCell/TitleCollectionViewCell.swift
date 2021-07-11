//
//  TitleCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/16.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {

    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let supplementalyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.build {
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        }

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .black
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.build {
            iconImageView.heightAnchor.constraint(equalToConstant: 36)
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        }

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        supplementalyLabel.font = .systemFont(ofSize: 24, weight: .bold)
        stackView.addArrangedSubview(supplementalyLabel)
    }

    func configure(
        icon: UIImage? = nil,
        title: String,
        supplementalyTitle: String = ""
    ) {
        if let icon = icon {
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        titleLabel.text = title
        supplementalyLabel.text = supplementalyTitle
    }
}
