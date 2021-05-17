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
        layer.cornerRadius = 20
        contentView.layer.cornerRadius = 20
    }
    
    func configure(course: FIDocument.Course) {
        courseNameLabel.text = course.name
        infoLabel.text = course.grade.name

        FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(course.registedUserId)
            .getDocument(FIDocument.User.self)
            .catch { _ -> Just<FIDocument.User?> in
                return .init(nil)
            }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.userView.configure(
                    user: user,
                    registeredDate: course.createdAt
                )
            }
            .store(in: &bindings)
        
        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Course.self,
                documentId: course.id,
                imageType: .header
            )
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
