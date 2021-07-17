//
//  TextViewCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/16.
//

import UIKit

class TextViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: PlaceHolderTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func configurePlaceholder(_ placeholder: String) {
        textView.updatePlaceholder(placeholder)
    }
}
