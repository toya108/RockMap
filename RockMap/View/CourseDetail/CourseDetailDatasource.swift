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
        ){ [weak self] collectionView, indexPath, item in
            
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case let .headerImages(referece):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureHeaderImageCell(),
                    for: indexPath,
                    item: referece
                )
                
            case .buttons:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureButtonsCell(),
                    for: indexPath,
                    item: Dummy()
                )
                
            case let .registeredUser(user):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureUserCell(),
                    for: indexPath,
                    item: user
                )
                
            case .climbedNumber:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureClimbedNumberCell(),
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
    
    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
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
            
            cell.isBookMarked = UserDefaultsDataHolder.shared.bookMarkedCourseIDs.contains(self.viewModel.course.id)
            
            cell.bookMarkButton.addAction(
                .init { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    cell.bookMarkButton.pop()
                    
                    cell.isBookMarked.toggle()
                    
                    var ids = UserDefaultsDataHolder.shared.bookMarkedCourseIDs
                    
                    if cell.isBookMarked {
                        ids.append(self.viewModel.course.id)
                    } else {
                        if let index = ids.firstIndex(of: self.viewModel.course.id) {
                            ids.remove(at: index)
                        }
                    }
                },
                for: .touchUpInside
            )
            
            cell.completeButton.addAction(
                .init { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    if AuthManager.isLoggedIn {
                        self.presentRegisterClimbedBottomSheetViewController()
                    } else {
                        self.showNeedsLoginAlert(message: "完登を記録するにはログインが必要です。")
                    }
                },
                for: .touchUpInside
            )
        }
    }
    
    private func configureUserCell() -> UICollectionView.CellRegistration<
        LeadingRegisteredUserCollectionViewCell,
        CourseDetailViewModel.UserCellStructure
    > {
        .init(
            cellNib: .init(
                nibName: LeadingRegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, user in
            cell.configure(
                name: user.name,
                photoURL: user.photoURL,
                registeredDate: user.registeredDate
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
        ) { cell, _, _ in

        }
    }
    
    private func presentRegisterClimbedBottomSheetViewController() {
        let vc = RegisterClimbedBottomSheetViewController()
        
        let recodeButtonAction: UIAction = .init { [weak self] _ in
            
            guard
                let self = self,
                let type = FIDocument.Climbed.ClimbedRecordType.allCases.any(at: vc.climbedTypeSegmentedControl.selectedSegmentIndex)
            else {
                return
            }

            self.viewModel.registerClimbed(
                climbedDate: vc.climbedDatePicker.date,
                type: type
            ) { [weak self] result in

                guard let self = self else { return }

                switch result {
                case .success(_):
                    self.dismiss(animated: true)

                case let .failure(error):
                    break

                }
            }
        }
            
        present(vc, animated: true) {
            vc.configureRecordButton(recodeButtonAction)
        }
    }
}
