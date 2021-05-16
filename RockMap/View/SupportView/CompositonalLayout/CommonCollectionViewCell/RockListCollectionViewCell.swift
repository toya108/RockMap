//
//  RockListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/05.
//

import UIKit
import Combine

class RockListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    private var bindings = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        mainImageView.layer.cornerRadius = 8
    }

    func configure(_ rock: FIDocument.Rock) {
        titleLabel.text = rock.name
        addressLabel.text = rock.address
        descLabel.text = rock.desc
        mainImageView.loadImage(url: rock.headerUrl)
    }

}
