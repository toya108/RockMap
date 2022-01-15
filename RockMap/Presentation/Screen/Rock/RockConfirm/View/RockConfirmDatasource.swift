import UIKit

extension RockConfirmViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let labelCellRegistration = createLabelCell()
        let locationCellRegistration = createLocationCell()
        let imageCellRegistration = createImageCell()
        let registerButtonCellRegistration = createRegisterButtonCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case let .name(rockName):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: rockName
                )

            case let .desc(desc):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: desc
                )

            case let .location(locationStructure):
                return collectionView.dequeueConfiguredReusableCell(
                    using: locationCellRegistration,
                    for: indexPath,
                    item: locationStructure
                )

            case let .header(image):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageCellRegistration,
                    for: indexPath,
                    item: image
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

            case let .season(season):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: season.map(\.name).joined(separator: "/")
                )

            case let .lithology(lithology):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: lithology.name
                )

            case let .erea(erea):
                return collectionView.dequeueConfiguredReusableCell(
                    using: labelCellRegistration,
                    for: indexPath,
                    item: erea
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

    private func createLabelCell() -> UICollectionView.CellRegistration<
        LabelCollectionViewCell,
        String
    > {
        .init { cell, _, courseName in
            cell.configure(text: courseName)
        }
    }

    private func createLocationCell() -> UICollectionView.CellRegistration<
        RockLocationCollectionViewCell,
        LocationManager.LocationStructure
    > {
        .init { cell, _, locationStructure in
            cell.configure(locationStructure: locationStructure)
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
                confirmationButtonTapped: self.viewModel.input.registerRockSubject.send
            )
        }
    }
}
