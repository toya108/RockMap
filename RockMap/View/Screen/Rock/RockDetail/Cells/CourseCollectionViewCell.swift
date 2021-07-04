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
    
    func configure(
        course: FIDocument.Course,
        parentVc: UIViewController
    ) {
        courseNameLabel.text = "📜 " + course.name + course.grade.name
        courseImageView.loadImage(url: course.headerUrl)

        FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(course.registeredUserId)
            .getDocument(FIDocument.User.self)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .compactMap { $0 }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.userView.configure(
                    user: user,
                    registeredDate: course.createdAt,
                    parentVc: parentVc
                )
            }
            .store(in: &bindings)
    }

}
