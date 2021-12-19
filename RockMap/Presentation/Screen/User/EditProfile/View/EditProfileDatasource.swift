import UIKit

extension EditProfileViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let nameCellRegistration = createNameCell()
        let introductionCellRegistration = createIntroductionCell()
        let deletableImageCellRegistration = createDeletabelImageCell()
        let errorLabelCellRegistration = createErrorLabelCell()
        let imageSelectCellRegistration = createImageSelectCell()
        let socialLinkCellRegistration = createSocialLinkCell()
        let iconCellRegistration = createIconEditCell()

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

            case .introduction:
                return collectionView.dequeueConfiguredReusableCell(
                    using: introductionCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .header(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: deletableImageCellRegistration,
                    for: indexPath,
                    item: image
                )

            case let .error(error):
                return collectionView.dequeueConfiguredReusableCell(
                    using: errorLabelCellRegistration,
                    for: indexPath,
                    item: error
                )

            case .noImage:
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageSelectCellRegistration,
                    for: indexPath,
                    item: .header
                )

            case let .socialLink(socialLinkType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: socialLinkCellRegistration,
                    for: indexPath,
                    item: socialLinkType
                )

            case let .icon(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: iconCellRegistration,
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

            cell.textField.delegate = self
            cell.textField.text = self.viewModel.output.name
            cell.configurePlaceholder("ユーザー名を入力して下さい。")
            cell.textField.textDidChangedPublisher
                .sink(receiveValue: self.viewModel.input.nameSubject.send)
                .store(in: &self.bindings)
        }
    }

    private func createIntroductionCell() -> UICollectionView.CellRegistration<
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

            cell.textView.text = self.viewModel.output.introduction
            cell.configurePlaceholder("自己紹介を入力して下さい。")
            cell.textView.textDidChangedPublisher
                .sink(receiveValue: self.viewModel.input.introductionSubject.send)
                .store(in: &self.bindings)
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

                self.viewModel.input.deleteImageSubject.send(.header)
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

            self.pickerManager.presentImagePicker(
                sourceType: .camera,
                imageType: imageType
            )
        }

        let menu = UIMenu(title: "", children: [photoLibraryAction, cameraAction])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }

    private func createSocialLinkCell() -> UICollectionView.CellRegistration<
        IconTextFieldCollectionViewCell,
        Entity.User.SocialLinkType
    > {
        .init { [weak self] cell, _, socialLinkType in

            guard
                let self = self,
                let sociallink = self.viewModel.output.socialLinks.getLink(type: socialLinkType)
            else {
                return
            }

            cell.textField.delegate = self
            cell.textField.text = sociallink.link
            cell.configurePlaceholder(
                iconImage: socialLinkType.icon,
                placeholder: socialLinkType.placeHolder
            )

            cell.textField.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.socialLinkSubject.send(
                        .init(
                            linkType: socialLinkType,
                            link: text
                        )
                    )
                }
                .store(in: &self.bindings)
        }
    }

    private func createIconEditCell() -> UICollectionView.CellRegistration<
        IconEditCollectionViewCell,
        CrudableImage
    > {
        .init { [weak self] cell, _, image in

            cell.configure(image: image)

            self?.setupImageUploadButtonActions(
                button: cell.editButton, imageType: .icon
            )

            cell.deleteButton.addActionForOnce(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.viewModel.input.deleteImageSubject.send(.icon)
                },
                for: .touchUpInside
            )
        }
    }
}
