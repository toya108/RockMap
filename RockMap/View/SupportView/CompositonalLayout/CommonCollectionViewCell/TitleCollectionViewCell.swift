//
//  TitleCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/16.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {

    let stackView = UIStackView()
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

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
    }

    func configure(
        title: String,
        supplementalyTitle: String = ""
    ) {
        titleLabel.text = title
    }
}
