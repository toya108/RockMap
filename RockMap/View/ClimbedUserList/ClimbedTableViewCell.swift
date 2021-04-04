//
//  ClimbedTableViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit

class ClimbedTableViewCell: UITableViewCell {

    @IBOutlet weak var userView: UserView!
    @IBOutlet weak var climbedTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(
        user: FIDocument.User,
        climbedDate: Date,
        type: FIDocument.Climbed.ClimbedRecordType
    ) {
        userView.configure(
            userName: user.name,
            photoURL: user.photoURL,
            registeredDate: climbedDate
        )

        climbedTypeLabel.text = type.name
    }

}
