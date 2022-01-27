import UIKit

extension RockRegisterViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let nameCellRegistration = createNameCell()
        let descCellRegistration = createDescCell()
        let locationCellRegistration = createLocationCell()
        let imageSelectCellRegistration = createImageSelectCell()
        let deletabelImageCellRegistration = createDeletabelImageCell()
        let seasonCellRegistration = createSeasonCell()
        let lithologyCellRegistration = createLithologyCell()
        let areaCellRegistration = createareaCell()
        let confirmationButtonCellRegistration = createConfirmationButtonCell()
        let errorLabelCellRegistration = createErrorLabelCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case .name:
                return collectionView.dequeueConfiguredReusableCell(
                    using: nameCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .desc:
                return collectionView.dequeueConfiguredReusableCell(
                    using: descCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .area:
                return collectionView.dequeueConfiguredReusableCell(
                    using: areaCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .location(locationStructure):
                return collectionView.dequeueConfiguredReusableCell(
                    using: locationCellRegistration,
                    for: indexPath,
                    item: locationStructure
                )

            case let .noImage(imageType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageSelectCellRegistration,
                    for: indexPath,
                    item: imageType
                )

            case let .images(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: deletabelImageCellRegistration,
                    for: indexPath,
                    item: image
                )

            case let .season(season, isSelecting):
                return collectionView.dequeueConfiguredReusableCell(
                    using: seasonCellRegistration,
                    for: indexPath,
                    item: (season, isSelecting)
                )

            case let .lithology(lithology):
                return collectionView.dequeueConfiguredReusableCell(
                    using: lithologyCellRegistration,
                    for: indexPath,
                    item: lithology
                )

            case .confirmation:
                return collectionView.dequeueConfiguredReusableCell(
                    using: confirmationButtonCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .error(error):
                return collectionView.dequeueConfiguredReusableCell(
                    using: errorLabelCellRegistration,
                    for: indexPath,
                    item: error
                )

            case let .header(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: deletabelImageCellRegistration,
                    for: indexPath,
                    item: image
                )
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.setSideInset(0)
            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section]
                .headerTitle
        }

        datasource.supplementaryViewProvider = { collectionView, _, index in

            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
        return datasource
    }

    private func createNameCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.textField.text = self.viewModel.output.rockName
            cell.configurePlaceholder("岩名を入力して下さい。")
            cell.textField.delegate = self
            cell.textField.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.rockNameSubject.send(text)
                }
                .store(in: &self.bindings)
        }
    }

    private func createDescCell() -> UICollectionView.CellRegistration<
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

            cell.textView.text = self.viewModel.output.rockDesc
            cell.configurePlaceholder("課題の説明を入力して下さい。")
            cell.textView.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.rockDescSubject.send(text)
                }
                .store(in: &self.bindings)
        }
    }

    private func createLocationCell() -> UICollectionView.CellRegistration<
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

            cell.currentAddressButton.addActionForOnce(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.viewModel.input.locationSubject
                        .send(.init(location: LocationManager.shared.location))
                },
                for: .touchUpInside
            )

            cell.selectLocationButton.addActionForOnce(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .locationSelect, from: self)
                },
                for: .touchUpInside
            )
        }
    }

    private func createImageSelectCell() -> UICollectionView.CellRegistration<
        ImageSelactCollectionViewCell,
        Entity.Image.ImageType
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

    private func createDeletabelImageCell() -> UICollectionView.CellRegistration<
        DeletableImageCollectionViewCell,
        CrudableImage
    > {
        .init { cell, _, crudableImage in

            cell.configure(crudableImage: crudableImage) { [weak self] in

                guard let self = self else { return }

                self.viewModel.input.deleteImageSubject.send(crudableImage)
            }
        }
    }

    private func createSeasonCell() -> UICollectionView.CellRegistration<
        IconCollectionViewCell,
        (season: Entity.Rock.Season, isSelecting: Bool)
    > {
        .init { cell, _, season in
            cell.configure(icon: season.season.iconImage, title: season.season.name)
            cell.isSelecting = season.isSelecting
        }
    }

    private func createLithologyCell() -> UICollectionView.CellRegistration<
        SegmentedControllCollectionViewCell,
        Entity.Rock.Lithology
    > {
        .init { cell, _, lithology in
            if let selectedIndex = Entity.Rock.Lithology.allCases.firstIndex(of: lithology) {
                cell.set(index: selectedIndex)
            }

            cell.segmentedControl.addAction(
                .init { [weak self] action in

                    guard let self = self else { return }

                    guard
                        let segmentedControl = action.sender as? UISegmentedControl,
                        let selected = Entity.Rock.Lithology.allCases
                            .any(at: segmentedControl.selectedSegmentIndex)
                    else {
                        return
                    }

                    self.viewModel.input.lithologySubject.send(selected)

                },
                for: .valueChanged
            )
        }
    }

    private func createareaCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.textField.text = self.viewModel.output.area
            cell.configurePlaceholder("御岳、瑞牆、小川山など")
            cell.textField.delegate = self
            cell.textField.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.rockAreaSubject.send(text)
                }
                .store(in: &self.bindings)
        }
    }

    private func createConfirmationButtonCell() -> UICollectionView.CellRegistration<
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

    private func createErrorLabelCell() -> UICollectionView.CellRegistration<
        ErrorLabelCollectionViewCell,
        ValidationError
    > {
        .init { cell, _, error in
            cell.configure(message: error.description)
        }
    }

    private func setupImageUploadButtonActions(
        button: UIButton,
        imageType: Entity.Image.ImageType
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
