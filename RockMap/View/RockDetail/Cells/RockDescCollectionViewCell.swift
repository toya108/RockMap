//
//  RockDescCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/06.
//

import UIKit

class RockDescCollectionViewCell: UICollectionViewCell {
    var descLabel = UILabel()
    
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
        descLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: topAnchor),
            descLabel.leftAnchor.constraint(equalTo: leftAnchor),
            descLabel.rightAnchor.constraint(equalTo: rightAnchor),
            descLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
