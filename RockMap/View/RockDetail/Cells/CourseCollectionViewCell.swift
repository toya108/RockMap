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
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var userView: UserView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.cornerRadius = 8
        contentView.layer.cornerRadius = 8
    }
    
    func configure(courese: FIDocument.Course) {
        courseNameLabel.text = courese.name
        infoLabel.text = courese.grade.name
        
        FirestoreManager.fetchById(id: courese.registedUserId) { [weak self] (result: Result<FIDocument.User?, Error>) in
            
            guard let self = self else { return }
            
            guard
                case let .success(user) = result
            else {
                return
            }

            self.userView.configure(
                userName: user?.name ?? "",
                photoURL: user?.photoURL,
                registeredDate: courese.createdAt
            )
        }
        
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: courese.name
        )
        
        StorageManager.getHeaderReference(reference: reference) { [weak self] result in
            
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
