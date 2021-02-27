//
//  NoCourcesCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/10.
//

import UIKit

class NoCourcesCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        imageView.image = UIImage.AssetsImages.penguinGudaGuda
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        label.text = "まだ課題が登録されていません。"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: 16),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
