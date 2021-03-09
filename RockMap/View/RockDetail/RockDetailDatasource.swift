//
//  RockDetailDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import UIKit

extension RockDetailViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                
                guard let self = self else { return UICollectionViewCell() }
                
                switch item {
                case let .headerImages(referece):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureHeaderImageCell(),
                        for: indexPath,
                        item: referece
                    )

                case let .registeredUser(user):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRegisteredUserCell(),
                        for: indexPath,
                        item: user
                    )
                    
                case let .desc(desc):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRockDescCell(),
                        for: indexPath,
                        item: desc
                    )
                
                case let .map(rockLocation):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureLocationCell(),
                        for: indexPath,
                        item: rockLocation
                    )
                
                case let .courses(course):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureCoursesCell(),
                        for: indexPath,
                        item: course
                    )
                
                case .nocourse:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureNoCourseCell(),
                        for: indexPath,
                        item: Dummy()
                    )
                }
            }
        )
        
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
    
    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
        }
    }
    
    private func configureRegisteredUserCell() -> UICollectionView.CellRegistration<
        RegisteredUserCollectionViewCell,
        FIDocument.User
    > {
        .init(
            cellNib: .init(
                nibName: RegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, user in
            cell.userNameLabel.text = user.name
            cell.userIconImageView.loadImage(url: user.photoURL)
        }
    }
    
    private func configureRockDescCell() -> UICollectionView.CellRegistration<
        RockDescCollectionViewCell,
        String
    > {
        .init { cell, _, desc in
            cell.descLabel.text = desc
        }
    }
    
    private func configureLocationCell() -> UICollectionView.CellRegistration<
        RockLocationCollectionViewCell,
        RockDetailViewModel.RockLocation
    > {
        .init { cell, _, location in
            cell.configure(rockLocation: location)
            cell.mapView.delegate = self
        }
    }
    
    private func configureNoCourseCell() -> UICollectionView.CellRegistration<
        NoCoursesCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: NoCoursesCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in
            
            guard let self = self else { return }
            
            cell.addCourseButton.addAction(
                .init { _ in
                    self.presentCourseRegisterViewController()
                },
                for: .touchUpInside
            )
        }
    }
    
    private func configureCoursesCell() -> UICollectionView.CellRegistration<
        CourseCollectionViewCell,
        FIDocument.Course
    > {
        .init(
            cellNib: .init(
                nibName: CourseCollectionViewCell.className,
                bundle: nil
            )
        ) { _, _, _ in }
    }
    
}
