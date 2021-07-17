//
//  ListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/23.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        mainImageView.layer.cornerRadius = 8
        iconImageView.tintColor = .black
    }

    func configure(
        imageUrl: URL?,
        iconImage: UIImage? = nil,
        title: String,
        first: String?,
        second: String?,
        third: String?
    ) {
        mainImageView.loadImage(url: imageUrl)
        titleLabel.text = title

        if let iconImage = iconImage {
            iconImageView.image = iconImage
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }

        if let first = first {
            firstLabel.text = first
        } else {
            firstLabel.isHidden = true
        }

        if let second = second {
            secondLabel.text = second
        } else {
            secondLabel.isHidden = true
        }

        if let third = third {
            thirdLabel.text = third
        } else {
            thirdLabel.isHidden = true
        }
    }
}
