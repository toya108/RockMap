//
//  CourseDetailDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
                case let .headerImage(referece):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageCell(),
                        for: indexPath,
                        item: referece
                    )

                case .buttons:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureButtonsCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case .title:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureTitleCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case .registeredUser:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureUserCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case .climbedNumber:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureClimbedNumberCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .shape(shapes):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureShapeCell(),
                        for: indexPath,
                        item: .init(
                            image: UIImage.SystemImages.triangleLefthalfFill,
                            title: "岩質",
                            subTitle: shapes.map(\.name).joined(separator: "/")
                        )
                    )

                case let .desc(desc):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureDescCell(),
                        for: indexPath,
                        item: desc
                    )


                case let .image(reference):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageCell(radius: 8.0),
                        for: indexPath,
                        item: reference
                    )

                case .noImage:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureNoImageCell(),
                        for: indexPath,
                        item: Dummy()
                    )
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in
            
            guard let self = self else { return }
            
            supplementaryView.setSideInset(0)
            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section].headerTitle
        }
        
        datasource.supplementaryViewProvider = { [weak self] collectionView, _, index in
            
            guard let self = self else { return nil }
            
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
        return datasource
    }
    
}

extension CourseDetailViewController {
    
    private func configureImageCell(radius: CGFloat = 0.0) -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = radius
        }
    }
    
    private func configureButtonsCell() -> UICollectionView.CellRegistration<
        CompleteButtonCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: CompleteButtonCollectionViewCell.className,
                bundle: nil
            )
        ) {  [weak self] cell, _, _ in
            
            guard let self = self else { return }
            
            cell.completeButton.addAction(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .registerClimbed, from: self)
                },
                for: .touchUpInside
            )
        }
    }

    private func configureTitleCell() -> UICollectionView.CellRegistration<
        TitleCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                title: self.viewModel.courseName,
                supplementalyTitle: self.viewModel.course.grade.name
            )
        }
    }
    
    private func configureUserCell() -> UICollectionView.CellRegistration<
        LeadingRegisteredUserCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: LeadingRegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                user: self.viewModel.registeredUser,
                registeredDate: self.viewModel.registeredDate
            )
        }
    }
    
    private func configureClimbedNumberCell() -> UICollectionView.CellRegistration<
        ClimbedNumberCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: ClimbedNumberCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                total: self.viewModel.totalClimbedNumber?.total ?? 0 as Int,
                flash: self.viewModel.totalClimbedNumber?.flashTotal ?? 0 as Int,
                redPoint: self.viewModel.totalClimbedNumber?.redPointTotal ?? 0 as Int
            )
        }
    }

    private func configureShapeCell() -> UICollectionView.CellRegistration<
        ValueCollectionViewCell,
        ValueCollectionViewCell.ValueCellStructure
    > {
        .init(
            cellNib: .init(
                nibName: ValueCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, data in
            cell.configure(data)
        }
    }

    private func configureDescCell() -> UICollectionView.CellRegistration<
        DescCollectionViewCell,
        String
    > {
        .init { cell, _, desc in
            cell.descLabel.text = desc
        }
    }

    private func configureNoImageCell() -> UICollectionView.CellRegistration<
        NoImageCollectionViewCell,
        Dummy
    > {
        .init { _, _, _ in }
    }

}
