//
//  RockTableViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/28.
//

import UIKit

class RockTableViewCell: UITableViewCell {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        headerImageView.layer.cornerRadius = 8
    }

    func configure(rock: FIDocument.Rock) {
        nameLabel.text = rock.name
        addressLabel.text = rock.address

        let rockReference = StorageManager.makeReference(
            parent: FINameSpace.Rocks.self,
            child: rock.name
        )
        StorageManager.getHeaderReference(reference: rockReference) { [weak self] result in

            guard let self = self else { return }

            switch result {
                case let .success(reference):
                    self.headerImageView.loadImage(reference: reference)

                case let .failure(_):
                    break

            }
        }
    }
    
}
