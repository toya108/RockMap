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
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
