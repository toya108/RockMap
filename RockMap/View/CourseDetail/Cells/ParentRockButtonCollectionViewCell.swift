//
//  ParentRockButtonCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/23.
//

import UIKit

class ParentRockButtonCollectionViewCell: UICollectionViewCell {

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
        rockButton.setTitleColor(UIColor.Pallete.primaryGreen, for: .normal)
        rockButton.contentHorizontalAlignment = .leading
        rockButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rockButton)

        NSLayoutConstraint.activate([
            rockButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            rockButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rockButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rockButton.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func configure(title: String, didTap: @escaping () -> Void) {
        rockButton.setTitle(title, for: .normal)
        rockButton.addAction(
            .init { _ in

            },
            for: .touchUpInside
        )
    }
}
