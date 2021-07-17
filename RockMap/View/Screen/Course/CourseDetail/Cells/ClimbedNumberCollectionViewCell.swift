//
//  ClimbedNumberCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/21.
//

import UIKit

class ClimbedNumberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var totalNumberLabel: UILabel!
    @IBOutlet weak var totalFlashLabel: UILabel!
    @IBOutlet weak var totalRedPointLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 8
    }

    func configure(
        total: Int,
        flash: Int,
        redPoint: Int
    ) {
        totalNumberLabel.text = total.description
        totalFlashLabel.text = flash.description
        totalRedPointLabel.text = redPoint.description
    }
}
