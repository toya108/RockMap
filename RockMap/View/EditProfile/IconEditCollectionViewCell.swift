//
//  IconEditCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/16.
//

import UIKit

class IconEditCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()
    let blurView = UIView()
    let editButton = UIButton()
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

        layer.masksToBounds = false
        layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16

        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.bounds.height / 2

        blurView.alpha = 0.45
        blurView.backgroundColor = .darkGray

        editButton.setTitle("", for: .normal)
        editButton.tintColor = .white
        editButton.setImage(UIImage.SystemImages.cameraFill, for: .normal)

        [imageView, blurView, editButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)

            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: contentView.topAnchor),
                $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                $0.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
        }

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

    func configure(
        storage: UpdatableStorage,
        deleteButtonTapped: @escaping () -> Void
    ) {
        imageView.image = UIImage.AssetsImages.penguinGudaGuda
    }

    func configure(
        imageDataKind: ImageDataKind,
        deleteButtonTapped: @escaping () -> Void
    ) {
        imageView.image = UIImage.AssetsImages.penguinGudaGuda
//        switch imageDataKind {
//            case .data(let data):
//                imageView.image = UIImage(data: data.data)
//
//            case .storage(let storage):
//                if let data = storage.updateData {
//                    imageView.image = UIImage(data: data)
//                } else {
//                    imageView.loadImage(reference: storage.storageReference)
//                }
//        }
//
//        deleteButton.addAction(
//            .init { _ in
//                deleteButtonTapped()
//            },
//            for: .touchUpInside
//        )
    }
}
