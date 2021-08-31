//
//  RockHeaderCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

class RockHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rockImageView: UIImageView!
    @IBOutlet weak var rockNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 8
    }

    func configure(rockName: String, headerUrl: URL?) {
        rockImageView.loadImage(url: headerUrl)
        rockNameLabel.text = rockName
    }
}
