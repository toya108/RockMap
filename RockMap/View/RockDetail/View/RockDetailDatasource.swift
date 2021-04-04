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
                case let .header(referece):
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

                case let .containGrade(grades):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureValueCell(),
                        for: indexPath,
                        item: .init(
                            image: UIImage.SystemImages.docPlaintextFill,
                            title: "課題数",
                            subTitle: self.makeGradeNumberStrings(dic: grades)
                        )
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
                    
                case let .season(seasons):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureValueCell(),
                        for: indexPath,
                        item: .init(
                            image: UIImage.SystemImages.leafFill,
                            title: "シーズン",
                            subTitle: seasons.map(\.name).joined(separator: "/")
                        )
                    )
                case let .lithology(lithology):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureValueCell(),
                        for: indexPath,
                        item: .init(
                            image: UIImage.AssetsImages.rockFill,
                            title: "岩質",
                            subTitle: lithology.name
                        )
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

    private func makeGradeNumberStrings(dic: [FIDocument.Course.Grade: Int]) -> String {
        dic.map { $0.key.name + "/" + $0.value.description + "本" }.joined(separator: ",")
    }
    
}

extension RockDetailViewController {
    
    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
        }
    }
    
    private func configureRegisteredUserCell() -> UICollectionView.CellRegistration<
        LeadingRegisteredUserCollectionViewCell,
        FIDocument.User
    > {
        .init(
            cellNib: .init(
                nibName: LeadingRegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, user in
            cell.configure(user: user)
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
        LocationManager.LocationStructure
    > {
        .init { cell, _, location in
            cell.configure(locationStructure: location)
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
                    self.router.route(
                        to: .courseRegister,
                        from: self
                    )
                },
                for: .touchUpInside
            )
        }
    }
    
    private func configureValueCell() -> UICollectionView.CellRegistration<
        ValueCollectionViewCell,
        ValueCollectionViewCell.ValueCellStructure
    > {
        .init(
            cellNib: .init(
                nibName: ValueCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, structure in
            cell.configure(structure)
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
        ) { cell, _, course in
            cell.configure(courese: course)
        }
    }
    
}
