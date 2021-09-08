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
        errorLabel.numberOfLines = 0
        contentView.addSubview(errorLabel)
        errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = UIColor.Pallete.primaryPink
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
