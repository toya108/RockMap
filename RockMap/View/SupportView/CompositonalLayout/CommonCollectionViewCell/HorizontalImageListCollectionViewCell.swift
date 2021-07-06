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

    func configure(
        imageDataKind: ImageDataKind
    ) {
        switch imageDataKind {
            case .data(let data):
                imageView.image = UIImage(data: data.data)

            case .storage(let storage):
                if let data = storage.updateData {
                    imageView.image = UIImage(data: data)
                } else {
                    imageView.loadImage(reference: storage.storageReference)
                }
        }
    }

    func configure<D: FIDocumentProtocol>(image: CrudableImage<D>) {
        if let data = image.updateData {
            imageView.image = UIImage(data: data)

        } else if let storage = image.storageReference {
            imageView.loadImage(reference: storage)
        }
    }
    
}
