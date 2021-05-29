//
//  ListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/23.
//

import UIKit
import Combine

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!

    private var bindings = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        mainImageView.layer.cornerRadius = 8
    }

    func configure(
        imageUrl: URL?,
        title: String,
        first: String?,
        second: String?,
        third: String?
    ) {
        mainImageView.loadImage(url: imageUrl)
        titleLabel.text = title

        if let first = first {
            firstLabel.text = first
        } else {
            firstLabel.isHidden = true
        }

        if let second = second {
            secondLabel.text = second
        } else {
            secondLabel.isHidden = true
        }

        if let third = third {
            thirdLabel.text = third
        } else {
            thirdLabel.isHidden = true
        }
    }
}
