//
//  RockRegisterDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit

extension RockRegisterViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .name:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureNameCell(),
                    for: indexPath,
                    item: Dummy()
                )

            case .desc:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureDescCell(),
                    for: indexPath,
                    item: Dummy()
                )
            case let .location(locationStructure):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLocationCell(),
                    for: indexPath,
                    item: locationStructure
                )
                
            case let .noImage(imageType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureImageSelectCell(),
                    for: indexPath,
                    item: imageType
                )
                
            case let .images(data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureDeletabelImageCell(),
                    for: indexPath,
                    item: data
                )
                
            case .season(let season, let isSelecting):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureSeasonCell(),
                    for: indexPath,
                    item: (season, isSelecting)
                )
                
            case let .lithology(lithology):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureLithologyCell(),
                    for: indexPath,
                    item: lithology
                )
                
            case .confirmation:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureConfirmationButtonCell(),
                    for: indexPath,
                    item: Dummy()
                )
                
            case let .error(error):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureErrorLabelCell(),
                    for: indexPath,
                    item: error
                )

            case let .headerImage(data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureDeletabelImageCell(),
                    for: indexPath,
                    item: data
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
    
    private func configureNameCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in
            
            guard let self = self else { return }

            cell.textField.text = self.viewModel.rockName
            cell.configurePlaceholder("岩名を入力して下さい。")
            cell.textField.textDidChangedPublisher.assign(to: &self.viewModel.$rockName)
            cell.textField.delegate = self
        }
    }
    
    private func configureDescCell() -> UICollectionView.CellRegistration<
        TextViewCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: TextViewCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in
            
            guard let self = self else { return }

            cell.textView.text = self.viewModel.rockDesc
            cell.configurePlaceholder("課題の説明を入力して下さい。")
            cell.textView.textDidChangedPublisher.assign(to: &self.viewModel.$rockDesc)
        }
    }
    
    private func configureLocationCell() -> UICollectionView.CellRegistration<
        LocationSelectCollectionViewCell,
        LocationManager.LocationStructure
    > {
        .init(
            cellNib: .init(
                nibName: LocationSelectCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, locationStructure in
            
            cell.configure(locationStructure: locationStructure)
            
            cell.currentAddressButton.addAction(
                .init { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.viewModel.rockLocation.location = LocationManager.shared.location
                },
                for: .touchUpInside
            )
            
            cell.selectLocationButton.addAction(
                .init { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.router.route(to: .locationSelect, from: self)
                },
                for: .touchUpInside
            )
        }
    }
    
    private func configureImageSelectCell() -> UICollectionView.CellRegistration<
        ImageSelactCollectionViewCell,
        ImageType
    > {
        .init(
            cellNib: .init(
                nibName: ImageSelactCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, imageType in
            
            guard let self = self else { return }
            
            self.setupImageUploadButtonActions(
                button: cell.uploadButton,
                imageType: imageType
            )
        }
    }
    
    private func configureDeletabelImageCell() -> UICollectionView.CellRegistration<
        DeletableImageCollectionViewCell,
        IdentifiableData
    > {
        .init { cell, _, identifiableData in
            
            cell.configure(data: identifiableData.data) { [weak self] in
                
                guard let self = self else { return }

                if self.viewModel.rockHeaderImage == identifiableData {
                    self.viewModel.rockHeaderImage = nil
                    return
                }

                guard
                    let index = self.viewModel.rockImageDatas.firstIndex(of: identifiableData)
                else {
                    return
                }
                
                self.viewModel.rockImageDatas.remove(at: index)
            }
        }
    }
    
    private func configureSeasonCell() -> UICollectionView.CellRegistration<
        IconCollectionViewCell,
        (season: FIDocument.Rock.Season, isSelecting: Bool)
    > {
        .init { cell, _, season in
            cell.configure(icon: season.season.iconImage, title: season.season.name)
            cell.isSelecting = season.isSelecting
        }
    }
    
    private func configureLithologyCell() -> UICollectionView.CellRegistration<
        SegmentedControllCollectionViewCell,
        FIDocument.Rock.Lithology
    > {
        .init { cell, _, lithology in
            cell.configure(
                items: FIDocument.Rock.Lithology.allCases.map(\.name),
                selectedIndex: FIDocument.Rock.Lithology.allCases.firstIndex(of: lithology)
            )
            
            cell.segmentedControl.addAction(
                .init { [weak self] action in
                    
                    guard let self = self else { return }
                    
                    guard
                        let segmentedControl = action.sender as? UISegmentedControl,
                        let selected = FIDocument.Rock.Lithology.allCases.any(at: segmentedControl.selectedSegmentIndex)
                    else {
                        return
                    }
                    
                    self.viewModel.lithology = selected
                    
                },
                for: .valueChanged
            )
        }
    }
    
    private func configureConfirmationButtonCell() -> UICollectionView.CellRegistration<
        ConfirmationButtonCollectionViewCell,
        Dummy
    > {
        .init { cell, _, _ in
            cell.configure(title: "　登録内容を確認する　")
            cell.configure { [weak self] in
                
                guard let self = self else { return }

                self.router.route(to: .rockConfirm, from: self)
            }
        }
    }
    
    private func configureErrorLabelCell() -> UICollectionView.CellRegistration<
        ErrorLabelCollectionViewCell,
        ValidationError
    > {
        .init { cell, _, error in
            cell.configure(message: error.description)
        }
    }
    
    private func setupImageUploadButtonActions(
        button: UIButton,
        imageType: ImageType
    ) {
        let photoLibraryAction = UIAction(
            title: "フォトライブラリ",
            image: UIImage.SystemImages.folderFill
        ) { [weak self] _ in
            
            guard let self = self else { return }

            self.pickerManager.presentPhPicker(imageType: imageType)
        }
        
        let cameraAction = UIAction(
            title: "写真を撮る",
            image: UIImage.SystemImages.cameraFill
        ) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.pickerManager.presentImagePicker(sourceType: .camera, imageType: imageType)
        }
        
        let menu = UIMenu(title: "", children: [photoLibraryAction, cameraAction])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
}
