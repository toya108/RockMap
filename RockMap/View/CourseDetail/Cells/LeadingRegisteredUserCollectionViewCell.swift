//
//  LeadingRegisteredUserCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import UIKit

class LeadingRegisteredUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var registeredDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = 20
    }

    func configure(name: String, photoURL: URL?, registeredDate: Date?) {
        iconImageView.loadImage(url: photoURL)
        userNameLabel.text = "登録者：" + name
        
        guard let registeredDate = registeredDate else { return }
        
        let format = DateFormatter()
        format.timeStyle = .none
        format.dateStyle = .medium
        format.locale = .init(identifier: "ja_JP")
        registeredDateLabel.text = format.string(from: registeredDate)
    }
}
