//
//  CompleteButtonCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import UIKit

class CompleteButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var bookMarkButton: UIButton!
    
    var isBookMarked: Bool = false {
        didSet {
            bookMarkButton.setImage(
                isBookMarked ? UIImage.SystemImages.bookMarkFill : UIImage.SystemImages.bookMark,
                for: .normal
            )
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        completeButton.layer.cornerRadius = 8
        bookMarkButton.layer.borderWidth = 0.5
        bookMarkButton.layer.borderColor = UIColor.Pallete.primaryGreen.cgColor
        bookMarkButton.layer.cornerRadius = 22
    }
}
