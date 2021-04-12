//
//  CourseCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/09.
//

import UIKit
import Combine

class CourseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var userView: UserView!

    private var bindings = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.cornerRadius = 8
        contentView.layer.cornerRadius = 8
    }
    
    func configure(course: FIDocument.Course) {
        courseNameLabel.text = course.name
        infoLabel.text = course.grade.name

        course.registedUserReference
            .getDocument(FIDocument.User.self)
            .catch { _ -> Just<FIDocument.User?> in
                return .init(nil)
            }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.userView.configure(
                    userName: user?.name ?? "",
                    photoURL: user?.photoURL,
                    registeredDate: course.createdAt
                )
            }
            .store(in: &bindings)
        
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: course.name
        )
        
        StorageManager
            .getHeaderReference(reference)
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .sink { [weak self] reference in

                guard let self = self else { return }

                self.courseImageView.loadImage(reference: reference)
            }
            .store(in: &bindings)
    }

}
