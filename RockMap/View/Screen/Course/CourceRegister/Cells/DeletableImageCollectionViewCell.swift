//
//  DeletableImageCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/19.
//

import UIKit

class DeletableImageCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.SystemImages.xmarkCircleFill, for: .normal)
        deleteButton.tintColor = .white
        imageView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            deleteButton.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ])
    }
    
    func configure<D: FIDocumentProtocol>(
        image: CrudableImage<D>,
        deleteButtonTapped: @escaping () -> Void
    ) {

        if let data = image.updateData {
            imageView.image = UIImage(data: data)
        } else if let storage = image.storageReference {
            imageView.loadImage(reference: storage)
        }

        deleteButton.addAction(
            .init { _ in
                deleteButtonTapped()
            },
            for: .touchUpInside
        )
    }
}
