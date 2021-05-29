//
//  MyCLimbedListDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/27.
//

import UIKit

extension MyClimbedListViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case let .course(course):
                    let registration = UICollectionView.CellRegistration<
                        ClimbedCourseCollectionViewCell,
                        MyClimbedListViewModel.ClimbedCourse
                    >(
                        cellNib: .init(
                            nibName: ClimbedCourseCollectionViewCell.className,
                            bundle: nil
                        )
                    ) { cell, _, climbedCourse in
                        cell.courseHeaderImageView.loadImage(url: climbedCourse.course.headerUrl)
                        cell.courseNameLabel.text = climbedCourse.course.name + " " + climbedCourse.course.grade.name
                        cell.climbedDateLabel.text = "完登日: " + climbedCourse.climbed.climbedDate.string(dateStyle: .medium)
                        cell.climbedTypeLabel.text = "完登方法: " + climbedCourse.climbed.type.name
                    }

                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: course
                    )
            }

        }
        return datasource
    }

}
