//
//  NoCoursesCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/09.
//

import UIKit

class NoCoursesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var addCourseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 0.5
        
        addCourseButton.layer.cornerRadius = 8
        addCourseButton.layer.shadowOffset = .init(width: 1, height: 1)
        addCourseButton.layer.shadowOpacity = 0.2
        addCourseButton.layer.shadowRadius = 8
        addCourseButton.layer.cornerRadius = 8
    }
    
}
