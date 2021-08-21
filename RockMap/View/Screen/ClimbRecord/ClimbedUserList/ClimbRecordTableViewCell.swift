//
//  ClimbedTableViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit

class ClimbRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var userView: UserView!
    @IBOutlet weak var climbedTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(
        user: FIDocument.User,
        climbedDate: Date,
        type: Entity.ClimbRecord.ClimbedRecordType,
        parentVc: UIViewController
    ) {
        userView.configure(
            user: user,
            registeredDate: climbedDate,
            parentVc: parentVc
        )

        climbedTypeLabel.text = type.name
        climbedTypeLabel.textColor = type.color
    }

}

private extension Entity.ClimbRecord.ClimbedRecordType {

    var color: UIColor {
        switch self {
            case .flash:
                return UIColor.Pallete.primaryGreen

            case .redPoint:
                return UIColor.Pallete.primaryPink

        }
    }
    
}
