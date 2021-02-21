//
//  ConfirmationButtonColletionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/20.
//

import UIKit

class ConfirmationButtonCollectionViewCell: UICollectionViewCell {
    
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        button.setTitle("登録内容を確認する", for: .normal)
        button.layer.cornerRadius = Resources.Const.UI.View.radius
        button.backgroundColor = UIColor.Pallete.primaryGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -32)
        ])
    }
}
