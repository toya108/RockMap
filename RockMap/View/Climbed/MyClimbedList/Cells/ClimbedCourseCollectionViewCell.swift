//
//  ClimbedCourseCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/28.
//

import UIKit

class ClimbedCourseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var courseHeaderImageView: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var climbedDateLabel: UILabel!
    @IBOutlet weak var climbedTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        courseHeaderImageView.layer.cornerRadius = 8
    }

}
