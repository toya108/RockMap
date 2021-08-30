//
//  HorizontalImageListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/03.
//

import UIKit

class HorizontalImageListCollectionViewCell: UICollectionViewCell {
    
    let imageView = ZoomImagePresentableImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .systemGroupedBackground

        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(image: CrudableImage) {
        if let data = image.updateData {
            imageView.image = UIImage(data: data)

        } else if let storage = image.storageReference {
            imageView.loadImage(reference: storage)
        }
    }
    
}
