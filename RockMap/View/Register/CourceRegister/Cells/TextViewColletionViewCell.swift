//
//  TextViewColletionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/16.
//

import UIKit

class TextViewColletionViewCell: UICollectionViewCell {
    
    let textView = PlaceHolderTextView()
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
        backgroundColor = .white
        
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
        
        [textView, borderView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .gray
        NSLayoutConstraint.activate([
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        textView.isScrollEnabled = false
        textView.placeHolder = "課題名の特徴やおすすめポイントを入力して下さい。"
    }
}
