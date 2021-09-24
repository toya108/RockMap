import UIKit

extension CourseRegisterViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let rockCellRegistration = createRockCell()
        let courseNameCellRegistration = createCourseNameCell()
        let gradeSelectingCellRegistration = createGradeSelectingCell()
        let shapeCellRegistration = createShapeCell()
        let courseDescCellRegistration = createCourseDescCell()
        let imageSelectCellRegistration = createImageSelectCell()
        let confirmationButtonCellRegistration = createConfirmationButtonCell()
        let deletableImageCellRegistration = createDeletableImageCell()
        let errorLabelCellRegistration = createErrorLabelCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case .rock:
                return collectionView.dequeueConfiguredReusableCell(
                    using: rockCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .courseName:
                return collectionView.dequeueConfiguredReusableCell(
                    using: courseNameCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .grade(grade):
                return collectionView.dequeueConfiguredReusableCell(
                    using: gradeSelectingCellRegistration,
                    for: indexPath,
                    item: grade
                )

            case .desc:
                return collectionView.dequeueConfiguredReusableCell(
                    using: courseDescCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .shape(shape, isSelecting):
                return collectionView.dequeueConfiguredReusableCell(
                    using: shapeCellRegistration,
                    for: indexPath,
                    item: (shape, isSelecting)
                )

            case let .noImage(imageType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageSelectCellRegistration,
                    for: indexPath,
                    item: imageType
                )

            case let .header(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: deletableImageCellRegistration,
                    for: indexPath,
                    item: image
                )

            case let .images(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: deletableImageCellRegistration,
                    for: indexPath,
                    item: image
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
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.setSideInset(0)
            supplementaryView.backgroundColor = .white
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

    private func createRockCell() -> UICollectionView.CellRegistration<
        RockHeaderCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: RockHeaderCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard
                let self = self,
                case let .create(rockHeader) = self.viewModel.registerType
            else {
                return
            }

            cell.configure(rockName: rockHeader.name, headerUrl: rockHeader.headerUrl)
        }
    }

    private func createCourseNameCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.textField.delegate = self
            cell.textField.text = self.viewModel.output.courseName
            cell.configurePlaceholder("課題名を入力して下さい。")
            cell.textField.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.courseNameSubject.send(text)
                }
                .store(in: &self.bindings)
        }
    }

    private func createGradeSelectingCell() -> UICollectionView.CellRegistration<
        GradeSelectingCollectionViewCell,
        Entity.Course.Grade
    > {
        .init(
            cellNib: .init(
                nibName: GradeSelectingCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, grade in

            guard let self = self else { return }

            cell.configure(grade: grade)
            self.setupGradeSelectingButtonActions(button: cell.gradeSelectButton)
        }
    }

    private func createShapeCell() -> UICollectionView.CellRegistration<
        IconCollectionViewCell,
        (shape: Entity.Course.Shape, isSelecting: Bool)
    > {
        .init { cell, _, shape in
            cell.configure(title: shape.shape.name)
            cell.isSelecting = shape.isSelecting
        }
    }

    private func createCourseDescCell() -> UICollectionView.CellRegistration<
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

            cell.textView.text = self.viewModel.output.courseDesc
            cell.configurePlaceholder("課題の説明を入力して下さい。")
            cell.textView.textDidChangedPublisher
                .sink { [weak self] text in

                    guard let self = self else { return }

                    self.viewModel.input.courseDescSubject.send(text)
                }
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

    private func createDeletableImageCell() -> UICollectionView.CellRegistration<
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

    private func createConfirmationButtonCell() -> UICollectionView.CellRegistration<
        ConfirmationButtonCollectionViewCell,
        Dummy
    > {
        .init { cell, _, _ in
            cell.configure(title: "　登録内容を確認する　")
            cell.configure { [weak self] in

                guard let self = self else { return }

                self.router.route(to: .courseConfirm, from: self)
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

    private func setupGradeSelectingButtonActions(button: UIButton) {
        let gradeSelectActions = Entity.Course.Grade.allCases.map { grade -> UIAction in
            .init(
                title: grade.name,
                state: viewModel.output.grade == grade ? .on : .off
            ) { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.input.gradeSubject.send(grade)
            }
        }

        let menu = UIMenu(title: "グレード選択", children: gradeSelectActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
}

struct Dummy {}
