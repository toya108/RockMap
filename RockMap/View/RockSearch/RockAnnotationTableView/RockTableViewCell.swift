//
//  RockTableViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/28.
//

import UIKit
import Combine

class RockTableViewCell: UITableViewCell {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    private var bindings = Set<AnyCancellable>()

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
        StorageManager
            .getHeaderReference(rockReference)
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .sink { [weak self] reference in

                guard let self = self else { return }

                self.headerImageView.loadImage(reference: reference)
            }
            .store(in: &bindings)
    }
    
}
