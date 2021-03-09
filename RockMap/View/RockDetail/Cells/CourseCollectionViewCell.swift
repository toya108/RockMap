//
//  CourseCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/09.
//

import UIKit

class CourseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var courseImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        courseImageView.layer.cornerRadius = 8
        userIconImageView.layer.cornerRadius = 22
    }

}
