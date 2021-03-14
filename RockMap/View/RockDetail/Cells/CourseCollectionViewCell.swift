//
//  CourseCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/09.
//

import UIKit

class CourseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var courseImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowOffset = .init(width: 2, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        layer.cornerRadius = 8
        contentView.layer.cornerRadius = 8
        
        userIconImageView.layer.cornerRadius = 22
    }
    
    func configure(courese: FIDocument.Course) {
        courseNameLabel.text = courese.name
        infoLabel.text = courese.grade.name
        
        FirestoreManager.fetchById(id: courese.registedUserId) { [weak self] (result: Result<FIDocument.User?, Error>) in
            
            guard let self = self else { return }
            
            guard
                case let .success(user) = result
            else {
                self.userNameLabel.text = "-"
                self.userIconImageView.image = UIImage.AssetsImages.noimage
                return
            }
            
            self.userNameLabel.text = user?.name
            self.userIconImageView.loadImage(url: user?.photoURL)
        }
        
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: courese.name
        )
        
        StorageManager.getFirstReference(reference: reference) { [weak self] result in
            
            guard let self = self else { return }
            
            guard
                case let .success(ref) = result
            else {
                self.courseImageView.image = UIImage.AssetsImages.noimage
                return
            }
            
            self.courseImageView.loadImage(reference: ref)
        }
    }

}
