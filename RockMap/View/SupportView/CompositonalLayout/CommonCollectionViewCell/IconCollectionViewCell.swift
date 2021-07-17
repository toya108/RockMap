//
//  IconCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/12.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    var isSelecting: Bool = false {
        didSet {
            if isSelecting {
                layer.borderColor = UIColor.Pallete.primaryGreen.cgColor
                layer.borderWidth = 1.5
                titleLabel.textColor = UIColor.Pallete.primaryGreen
                titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
            } else {
                layer.borderColor = UIColor.gray.cgColor
                layer.borderWidth = 1
                titleLabel.textColor = .gray
                titleLabel.font = .systemFont(ofSize: 17)
            }
        }
    }
    
    private func setupLayout() {
        layer.cornerRadius = 8
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
        ])
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .gray
        stackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(icon: UIImage? = nil, title: String) {
        if
            let icon = icon
        {
            iconImageView.image = icon
        } else {
            stackView.arrangedSubviews.first(where: { $0 === iconImageView })?.removeFromSuperview()
        }
        
        titleLabel.text = title
    }
}
