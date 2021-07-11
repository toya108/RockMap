//
//  CourseListDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/05.
//

import UIKit

extension CourseListViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case .annotationHeader:
                    let registration = UICollectionView.CellRegistration<
                        AnnotationHeaderCollectionViewCell,
                        Dummy
                    > { cell, _, _ in
                        cell.configure(title: "課題を長押しすると編集/削除ができます。")
                    }

                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: Dummy()
                    )

                case let .course(course):
                    let registration = UICollectionView.CellRegistration<
                        ListCollectionViewCell,
                        FIDocument.Course
                    >(
                        cellNib: .init(
                            nibName: ListCollectionViewCell.className,
                            bundle: nil
                        )
                    ) { cell, _, _ in
                        cell.configure(
                            imageUrl: course.headerUrl,
                            iconImage: UIImage.SystemImages.docPlaintextFill,
                            title: course.name + " " + course.grade.name,
                            first: "登録日: " + course.createdAt.string(dateStyle: .medium),
                            second: "岩名: " + course.parentRockName,
                            third: course.desc
                        )
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
