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
                case .headerImage:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageCell(),
                        for: indexPath,
                        item: self.viewModel.course.headerUrl
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

                case .parentRock:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRockCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .shape(cellData):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureShapeCell(),
                        for: indexPath,
                        item: cellData
                    )

                case .desc:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureDescCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .image(url):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageCell(radius: 8.0),
                        for: indexPath,
                        item: url
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
        URL?
    > {
        .init { cell, _, url in
            cell.imageView.loadImage(url: url)
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
                title: self.viewModel.course.name,
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

            guard
                let self = self,
                let user = self.viewModel.output.fetchRegisteredUserState.content
            else {
                return
            }

            cell.configure(
                user: user,
                registeredDate: self.viewModel.course.createdAt,
                parentVc: self
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

            let flash = self.viewModel.output.totalClimbedNumber?.flashTotal ?? 0
            let redPoint =  self.viewModel.output.totalClimbedNumber?.redPointTotal ?? 0
            cell.configure(
                total: flash + redPoint,
                flash: flash,
                redPoint: redPoint
            )
        }
    }

    private func configureRockCell() -> UICollectionView.CellRegistration<
        ParentRockButtonCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard
                let self = self,
                let rock = self.viewModel.output.fetchParentRockState.content
            else {
                return
            }

            cell.configure(title: rock.name) { [weak self] in

                guard let self = self else { return }

                self.router.route(to: .parentRock(rock), from: self)
            }
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
        Dummy
    > {
        .init { [weak self] cell, _, desc in

            guard let self = self else { return }

            cell.descLabel.text = self.viewModel.course.desc
        }
    }

    private func configureNoImageCell() -> UICollectionView.CellRegistration<
        NoImageCollectionViewCell,
        Dummy
    > {
        .init { _, _, _ in }
    }

}
