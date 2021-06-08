//
//  IconTextFieldCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/13.
//

import UIKit

class IconTextFieldCollectionViewCell: UICollectionViewCell {

    let iconImageView = UIImageView()
    let textField = UITextField()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        iconImageView.tintColor = .gray

        contentView.addSubview(stackView)
        stackView.spacing = 8
        stackView.axis = .horizontal

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32)
        ])

        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)

    }

    func configurePlaceholder(iconImage: UIImage, placeholder: String) {
        textField.placeholder = placeholder
        iconImageView.image = iconImage
    }
}
