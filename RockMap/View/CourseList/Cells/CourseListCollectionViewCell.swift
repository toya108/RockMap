//
//  CourseListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/23.
//

import UIKit
import Combine

class CourseListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var rockNameLabel: UILabel!

    private var bindings = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        mainImageView.layer.cornerRadius = 8
    }

    func configure(course: FIDocument.Course) {
        titleLabel.text = course.name
        gradeLabel.text = "グレード：" + course.grade.name
        rockNameLabel.text = "岩名：" + course.parentRockName


        StorageManager
            .getHeaderReference(
                destinationDocument: FINameSpace.Course.self,
                documentId: course.id
            )
            .catch { _ in Empty() }
            .sink { [weak self] reference in

                guard let self = self else { return }

                self.mainImageView.loadImage(reference: reference)
            }
            .store(in: &bindings)
    }
}
