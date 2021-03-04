//
//  LabelCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/04.
//

import UIKit

class LabelCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    func configure(text: String) {
        label.text = text
    }
    
    private func setupLayout() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
