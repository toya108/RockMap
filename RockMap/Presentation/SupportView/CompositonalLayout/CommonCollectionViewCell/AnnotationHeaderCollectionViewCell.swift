//
//  AnnotationHeaderCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/28.
//

import UIKit

class AnnotationHeaderCollectionViewCell: UICollectionViewCell {

    let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            headerLabel.rightAnchor.constraint(equalTo: rightAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        headerLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    }

    func configure(
        title: String
    ) {
        headerLabel.text = title
    }
}
