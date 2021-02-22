//
//  TextFieldColletionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/13.
//

import UIKit

class TextFieldColletionViewCell: UICollectionViewCell {
    
    let textField = UITextField()
    let stackView = UIStackView()
    let borderView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(stackView)
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
        
        [textField, borderView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        textField.placeholder = "課題名を入力して下さい。"
    }
}
