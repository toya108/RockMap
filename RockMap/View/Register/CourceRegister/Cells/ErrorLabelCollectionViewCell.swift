//
//  ErrorLabelCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/23.
//

import UIKit

class ErrorLabelCollectionViewCell: UICollectionViewCell {
    
    let errorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    func configure(message: String) {
        errorLabel.text = "※" + message
    }
    
    private func setupLayout() {
        addSubview(errorLabel)
        errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = UIColor.Pallete.primaryPink
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: topAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
    }
}
