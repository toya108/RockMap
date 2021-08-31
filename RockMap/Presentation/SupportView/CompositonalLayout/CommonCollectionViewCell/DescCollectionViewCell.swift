//
//  DescCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/06.
//

import UIKit

class DescCollectionViewCell: UICollectionViewCell {
    
    let descLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(descLabel)
        descLabel.numberOfLines = 0
        descLabel.textColor = .darkGray
        descLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: topAnchor),
            descLabel.leftAnchor.constraint(equalTo: leftAnchor),
            descLabel.rightAnchor.constraint(equalTo: rightAnchor),
            descLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
