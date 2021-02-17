//
//  TextViewCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/16.
//

import UIKit

class TextViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }
}
