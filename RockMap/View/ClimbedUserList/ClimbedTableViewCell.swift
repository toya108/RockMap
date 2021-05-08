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
    }

    func configure(
        user: FIDocument.User,
        climbedDate: Date,
        type: FIDocument.Climbed.ClimbedRecordType
    ) {
        userView.configure(
            prefix: "",
            userName: user.name,
            photoURL: user.photoURL,
            registeredDate: climbedDate
        )

        climbedTypeLabel.text = type.name
        climbedTypeLabel.textColor = type.color
    }

}
