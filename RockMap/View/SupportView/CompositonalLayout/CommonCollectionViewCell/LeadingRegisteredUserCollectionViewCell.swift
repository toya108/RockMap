//
//  LeadingRegisteredUserCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import UIKit

class LeadingRegisteredUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userView: UserView!

    func configure(
        user: FIDocument.User,
        registeredDate: Date? = nil,
        parentVc: UIViewController
    ) {
        userView.configure(
            user: user,
            registeredDate: registeredDate,
            parentVc: parentVc
        )
    }
}
