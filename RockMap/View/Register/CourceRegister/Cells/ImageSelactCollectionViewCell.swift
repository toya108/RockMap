//
//  ImageSelactCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/18.
//

import UIKit

class ImageSelactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        
        uploadButton.layer.cornerRadius = 8
        uploadButton.titleLabel?.numberOfLines = 0
    }

}
