//
//  CompleteButtonCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import UIKit

class CompleteButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var completeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        completeButton.layer.cornerRadius = 8
    }
}
