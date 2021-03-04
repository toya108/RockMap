//
//  CourceConfirmDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import UIKit

extension CourseConfirmViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case let .rock(rock):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureRockCell(),
                    for: indexPath,
                    item: rock
                )
            
            default:
                return UICollectionViewCell()
                
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in
            
            guard let self = self else { return }
            
            supplementaryView.setSideInset(0)
            supplementaryView.backgroundColor = .white
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
    
    private func configureRockCell() -> UICollectionView.CellRegistration<
        RockHeaderCollectionViewCell,
        CourceRegisterViewModel.RockHeaderStructure
    > {
        .init(
            cellNib: .init(
                nibName: RockHeaderCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, rockHeaderStructure in
            cell.configure(rockHeaderStructure: rockHeaderStructure)
        }
    }
}
