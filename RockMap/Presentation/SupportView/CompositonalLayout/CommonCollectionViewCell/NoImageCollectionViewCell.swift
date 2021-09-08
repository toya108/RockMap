//
//  NoImageCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/14.
//

import UIKit

class NoImageCollectionViewCell: UICollectionViewCell {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 8
        addSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "画像は未投稿です。"
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
