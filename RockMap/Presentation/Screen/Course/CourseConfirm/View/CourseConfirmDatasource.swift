import UIKit

extension CourseConfirmViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let labelCellRegistration = createLabelCell()
        let rockCellRegistration = createRockCell()
        let imageCellRegistration = createImageCell()
        let registerButtonCellRegistration = createRegisterButtonCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case let .rock(rockName, headerUrl):
                return collectionView.dequeueConfiguredReusableCell(
                    using: rockCellRegistration,
                    for: indexPath,
                    item: (rockName, headerUrl)
                )

            case let .courseName(courseName):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: courseName
                )

            case let .desc(desc):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: desc
                )

            case let .grade(grade):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: grade.name
                )

            case let .shape(shape):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: shape.map(\.name).joined(separator: "/")
                )

            case let .header(header):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageCellRegistration,
                    for: indexPath,
                    item: header
                )

            case let .images(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageCellRegistration,
                    for: indexPath,
                    item: image
                )

            case .register:
                return collectionView.dequeueConfiguredReusableCell(
                    using: registerButtonCellRegistration,
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
        (rockName: String, headerUrl: URL?)
    > {
        .init(
            cellNib: .init(
                nibName: RockHeaderCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, rockHeaderStructure in
            cell.configure(
                rockName: rockHeaderStructure.rockName,
                headerUrl: rockHeaderStructure.headerUrl
            )
        }
    }

    private func createLabelCell() -> UICollectionView.CellRegistration<
        LabelCollectionViewCell,
        String
    > {
        .init { cell, _, courseName in
            cell.configure(text: courseName)
        }
    }

    private func createImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        CrudableImage
    > {
        .init { cell, _, crudableImage in
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            cell.configure(crudableImage: crudableImage)
        }
    }

    private func createRegisterButtonCell() -> UICollectionView.CellRegistration<
        ConfirmationButtonCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(title: "　登録する　")
            cell.configure(
                confirmationButtonTapped: self.viewModel.input.registerCourseSubject.send
            )
        }
    }
}
