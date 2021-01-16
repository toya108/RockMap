//
//  TabCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/15.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    private var image = UIImage.AssetsImages.noImage
    private var selectingImage = UIImage.AssetsImages.noImage
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? UIColor.Pallete.primaryGreen : .lightGray
            iconImageVIew.tintColor = isSelected ? UIColor.Pallete.primaryGreen : .lightGray
            iconImageVIew.image = isSelected ? selectingImage : image
        }
    }
    
    func setContents(title: String, image: UIImage, selectingImage: UIImage) {
        titleLabel.text = title
        self.image = image
        iconImageVIew.image = image
        self.selectingImage = selectingImage
    }
}
