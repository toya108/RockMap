//
//  TitleHeaderView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/07.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    
    func setSideInset(_ inset: CGFloat) {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset)
        ])
    }
}
