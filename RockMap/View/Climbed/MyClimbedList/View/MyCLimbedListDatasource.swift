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
                    ) { cell, _, _ in


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
