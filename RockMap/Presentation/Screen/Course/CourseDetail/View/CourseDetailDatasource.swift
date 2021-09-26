import UIKit

extension CourseDetailViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let headerImageCellRegistration = createHeaderImageCell()
        let buttonsCellRegistration = createButtonsCell()
        let titleCellRegistration = createTitleCell()
        let userCellRegistration = createUserCell()
        let climbedNumberCellRegistration = createClimbedNumberCell()
        let rockCellRegistration = createRockCell()
        let shapeCellRegistration = createShapeCell()
        let descCellRegistration = createDescCell()
        let imageCellRegistration = createImageCell()
        let noImageCellRegistration = createNoImageCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case let .headerImage(url):
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerImageCellRegistration,
                    for: indexPath,
                    item: url
                )

            case .buttons:
                return collectionView.dequeueConfiguredReusableCell(
                    using: buttonsCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .title:
                return collectionView.dequeueConfiguredReusableCell(
                    using: titleCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .registeredUser:
                return collectionView.dequeueConfiguredReusableCell(
                    using: userCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .climbedNumber:
                return collectionView.dequeueConfiguredReusableCell(
                    using: climbedNumberCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .parentRock:
                return collectionView.dequeueConfiguredReusableCell(
                    using: rockCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .shape(cellData):
                return collectionView.dequeueConfiguredReusableCell(
                    using: shapeCellRegistration,
                    for: indexPath,
                    item: cellData
                )

            case .desc:
                return collectionView.dequeueConfiguredReusableCell(
                    using: descCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .image(url):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageCellRegistration,
                    for: indexPath,
                    item: url
                )

            case .noImage:
                return collectionView.dequeueConfiguredReusableCell(
                    using: noImageCellRegistration,
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
}

extension CourseDetailViewController {
    private func createHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        URL
    > {
        .init { cell, _, url in
            cell.imageView.loadImage(url: url)
        }
    }

    private func createImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        URL
    > {
        .init { cell, _, url in
            cell.imageView.loadImage(url: url)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8.0
        }
    }

    private func createButtonsCell() -> UICollectionView.CellRegistration<
        CompleteButtonCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: CompleteButtonCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.completeButton.addActionForOnce(
                .init { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .registerClimbed, from: self)
                },
                for: .touchUpInside
            )
        }
    }

    private func createTitleCell() -> UICollectionView.CellRegistration<
        TitleCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                icon: UIImage.SystemImages.docPlaintextFill,
                title: self.viewModel.course.name,
                supplementalyTitle: self.viewModel.course.grade.name
            )
        }
    }

    private func createUserCell() -> UICollectionView.CellRegistration<
        LeadingRegisteredUserCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: LeadingRegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard
                let self = self,
                let user = self.viewModel.output.fetchRegisteredUserState.content
            else {
                return
            }

            cell.configure(
                user: user,
                registeredDate: self.viewModel.course.createdAt,
                parentVc: self
            )
        }
    }

    private func createClimbedNumberCell() -> UICollectionView.CellRegistration<
        ClimbedNumberCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: ClimbedNumberCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            let total = self.viewModel.output.totalClimbedNumber.total
            let flash = self.viewModel.output.totalClimbedNumber.flash
            let redPoint = self.viewModel.output.totalClimbedNumber.redPoint
            cell.configure(
                total: total,
                flash: flash,
                redPoint: redPoint
            )
        }
    }

    private func createRockCell() -> UICollectionView.CellRegistration<
        ParentRockButtonCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard
                let self = self,
                let rock = self.viewModel.output.fetchParentRockState.content
            else {
                return
            }

            cell.configure(title: rock.name) { [weak self] in

                guard let self = self else { return }

                self.router.route(to: .parentRock(rock), from: self)
            }
        }
    }

    private func createShapeCell() -> UICollectionView.CellRegistration<
        ValueCollectionViewCell,
        ValueCollectionViewCell.ValueCellStructure
    > {
        .init(
            cellNib: .init(
                nibName: ValueCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, data in
            cell.configure(data)
        }
    }

    private func createDescCell() -> UICollectionView.CellRegistration<
        DescCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.descLabel.text = self.viewModel.course.desc
        }
    }

    private func createNoImageCell() -> UICollectionView.CellRegistration<
        NoImageCollectionViewCell,
        Dummy
    > {
        .init { _, _, _ in }
    }
}
