//
//  GradeSelectingCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/14.
//

import UIKit

class GradeSelectingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var gradeLabel: UILabel!
    
    var grade: FIDocument.Cource.Grade = .q10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4
    }
    
    func configure(grade: FIDocument.Cource.Grade) {
        gradeLabel.text = grade.name
        self.grade = grade
    }
    
}
