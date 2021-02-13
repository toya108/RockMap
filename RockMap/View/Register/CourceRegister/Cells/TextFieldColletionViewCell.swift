//
//  TextFieldColletionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/13.
//

import UIKit

class TextFieldColletionViewCell: UICollectionViewCell {
    
    let textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .white
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
    }
}
