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
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
    }

    func configure(rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure) {
        rockImageView.loadImage(reference: rockHeaderStructure.rockImageReference)
        rockNameLabel.text = rockHeaderStructure.rockName
        userIconImageView.loadImage(url: rockHeaderStructure.userIconPhotoURL)
        userNameLabel.text = rockHeaderStructure.userName
    }
}
