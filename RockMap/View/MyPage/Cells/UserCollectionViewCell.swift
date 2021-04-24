//
//  UserCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var userView: UserView!

    override func awakeFromNib() {
        super.awakeFromNib()

        editProfileButton.layer.cornerRadius = 8
    }
}
