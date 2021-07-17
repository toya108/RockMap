//
//  ValueCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/18.
//

import UIKit

class ValueCollectionViewCell: UICollectionViewCell {
    
    struct ValueCellStructure: Hashable {
        let image: UIImage
        let title: String
        let subTitle: String
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    func configure(_ data: ValueCellStructure) {
        iconImageView.image = data.image
        titleLabel.text = data.title
        subTitleLabel.text = data.subTitle
    }
}
