//
//  courseConfirmDatasource.swift
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
                
            case let .courseName(courseName):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLabelCell(),
                    for: indexPath,
                    item: courseName
                )
                
            case let .desc(desc):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLabelCell(),
                    for: indexPath,
                    item: desc
                )
                
            case let .grade(grade):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLabelCell(),
                    for: indexPath,
                    item: grade.name
                )
                
            case let .shape(shape):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLabelCell(),
                    for: indexPath,
                    item: shape.map(\.name).joined(separator: "/")
                )

            case let .header(header):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureImageCell(),
                    for: indexPath,
                    item: header
                )
                
            case let .images(image):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureImageCell(),
                    for: indexPath,
                    item: image
                )
                
            case .register:
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.configureRegisterButtonCell(),
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
        CourseRegisterViewModel.RockHeaderStructure
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
    
    private func configureLabelCell() -> UICollectionView.CellRegistration<
        LabelCollectionViewCell,
        String
    > {
        .init { cell, _, courseName in
            cell.configure(text: courseName)
        }
    }
    
    private func configureImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        ImageDataKind
    > {
        .init { cell, _, imageDataKind in
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            cell.configure(imageDataKind: imageDataKind)
        }
    }
    
    private func configureRegisterButtonCell() -> UICollectionView.CellRegistration<
        ConfirmationButtonCollectionViewCell,
        Dummy
    > {
        .init { cell, _, _ in
            cell.configure(title: "　登録する　")
            cell.configure { [weak self] in
                
                guard let self = self else { return }
                
                self.viewModel.uploadImages()
            }
        }
    }
}
