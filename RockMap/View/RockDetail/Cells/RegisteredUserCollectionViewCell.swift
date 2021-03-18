//
//  RegisteredUserCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/04.
//

import UIKit

class RegisteredUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userIconImageView.layer.cornerRadius = 22
    }
}
