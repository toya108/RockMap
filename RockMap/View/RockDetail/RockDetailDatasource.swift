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
                
                case .cources:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureCourcesCell(),
                        for: indexPath,
                        item: nil
                    )
                
                case .noCource:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureNoCourceCell(),
                        for: indexPath,
                        item: "aaa"
                    )
                    
                }
            }
        )
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in
            
            guard let self = self else { return }

            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section].headerTitle
        }
        
        datasource.supplementaryViewProvider = { [weak self] collectionView, kind, index in
            
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
        FIDocument.Users
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
        }
    }
    
    private func configureNoCourceCell() -> UICollectionView.CellRegistration<
        NoCourcesCollectionViewCell,
        String
    > {
        .init { _, _, _ in }
    }
    
    private func configureCourcesCell() -> UICollectionView.CellRegistration<
        NoCourcesCollectionViewCell,
        Never
    > {
        .init { _, _, _ in }
    }
    
}
