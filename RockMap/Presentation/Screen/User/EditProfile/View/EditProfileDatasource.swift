//
//  EditProfileDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//

import UIKit

extension EditProfileViewController {

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

                case .introduction:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureIntroductionCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .header(image):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureDeletabelImageCell(),
                        for: indexPath,
                        item: image
                    )

                case let .error(error):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureErrorLabelCell(),
                        for: indexPath,
                        item: error
                    )
                    
                case .noImage:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageSelectCell(),
                        for: indexPath,
                        item: .header
                    )

                case .socialLink(let socialLinkType):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureSocialLinkCell(),
                        for: indexPath,
                        item: socialLinkType
                    )

                case let .icon(image):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureIconEditCell(),
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

    private func configureNameCell() -> UICollectionView.CellRegistration<
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

    private func configureIntroductionCell() -> UICollectionView.CellRegistration<
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

    private func configureImageSelectCell() -> UICollectionView.CellRegistration<
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

    private func configureDeletabelImageCell() -> UICollectionView.CellRegistration<
        DeletableImageCollectionViewCell,
        CrudableImageV2
    > {
        .init { cell, _, crudableImage in
            cell.configure(crudableImage: crudableImage) { [weak self] in

                guard let self = self else { return }

                self.viewModel.input.deleteImageSubject.send(.header)
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

    private func configureSocialLinkCell() -> UICollectionView.CellRegistration<
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

    private func configureIconEditCell() -> UICollectionView.CellRegistration<
        IconEditCollectionViewCell,
        CrudableImageV2
    > {
        .init { [weak self] cell, _, image in

            cell.configure(image: image)

            self?.setupImageUploadButtonActions(
                button: cell.editButton, imageType: .icon
            )

            cell.deleteButton.addAction(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.viewModel.input.deleteImageSubject.send(.icon)
                },
                for: .touchUpInside
            )
        }
    }

}
