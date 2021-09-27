import UIKit

extension RockDetailViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let headeriImageCellRegistration = createHeaderImageCell()
        let imageCellRegistration = createImageCell()
        let titleCellRegistration = createTitleCell()
        let registeredUserCellRegistration = createRegisteredUserCell()
        let rockDescCellRegistration = createRockDescCell()
        let locationCellRegistration = createLocationCell()
        let noCourseCellRegistration = createNoCourseCell()
        let valueCellRegistration = createValueCell()
        let courseCellRegistration = createCourseCell()
        let noImageCellRegistration = createNoImageCell()

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in

                guard let self = self else { return UICollectionViewCell() }

                switch item {
                case let .header(loadable):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: headeriImageCellRegistration,
                        for: indexPath,
                        item: loadable
                    )

                case let .title(title):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: titleCellRegistration,
                        for: indexPath,
                        item: title
                    )

                case let .registeredUser(user):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: registeredUserCellRegistration,
                        for: indexPath,
                        item: user
                    )

                case let .desc(desc):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: rockDescCellRegistration,
                        for: indexPath,
                        item: desc
                    )

                case let .map(rockLocation):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: locationCellRegistration,
                        for: indexPath,
                        item: rockLocation
                    )

                case let .containGrade(grades):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: valueCellRegistration,
                        for: indexPath,
                        item: .init(
                            image: UIImage.SystemImages.docPlaintextFill,
                            title: "課題数",
                            subTitle: self.viewModel.makeGradeNumberStrings(dic: grades)
                        )
                    )

                case let .courses(course):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: courseCellRegistration,
                        for: indexPath,
                        item: course
                    )

                case .nocourse:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: noCourseCellRegistration,
                        for: indexPath,
                        item: Dummy()
                    )

                case let .season(seasons):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: valueCellRegistration,
                        for: indexPath,
                        item: .init(
                            image: UIImage.SystemImages.leafFill,
                            title: "シーズン",
                            subTitle: seasons.map(\.name).joined(separator: "/")
                        )
                    )

                case let .lithology(lithology):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: valueCellRegistration,
                        for: indexPath,
                        item: .init(
                            image: UIImage.AssetsImages.rockFill,
                            title: "岩質",
                            subTitle: lithology.name
                        )
                    )

                case let .image(loadables):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: imageCellRegistration,
                        for: indexPath,
                        item: loadables
                    )

                case .noImage:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: noImageCellRegistration,
                        for: indexPath,
                        item: Dummy()
                    )
                }
            }
        )

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.setSideInset(0)
            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section]
                .headerTitle
        }

        datasource.supplementaryViewProvider = { [weak self] _, _, index in

            guard let self = self else { return nil }

            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
        return datasource
    }
}

extension RockDetailViewController {

    private func createHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        URL
    > {
        .init { cell, _, imageLoadable in
            cell.imageView.loadImage(url: imageLoadable)
        }
    }

    private func createImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        URL
    > {
        .init { cell, _, imageLoadable in

            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8.0
            cell.imageView.loadImage(url: imageLoadable)
        }
    }

    private func createTitleCell() -> UICollectionView.CellRegistration<
        TitleCollectionViewCell,
        String
    > {
        .init { cell, _, title in
            cell.configure(icon: UIImage.AssetsImages.rockFill, title: title)
        }
    }

    private func createRegisteredUserCell() -> UICollectionView.CellRegistration<
        LeadingRegisteredUserCollectionViewCell,
        Entity.User
    > {
        .init(
            cellNib: .init(
                nibName: LeadingRegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, user in

            guard let self = self else { return }

            cell.configure(
                user: user,
                registeredDate: self.viewModel.rockDocument.createdAt,
                parentVc: self
            )
        }
    }

    private func createRockDescCell() -> UICollectionView.CellRegistration<
        DescCollectionViewCell,
        String
    > {
        .init { cell, _, desc in
            cell.descLabel.text = desc
        }
    }

    private func createLocationCell() -> UICollectionView.CellRegistration<
        RockLocationCollectionViewCell,
        LocationManager.LocationStructure
    > {
        .init { cell, _, location in
            cell.configure(locationStructure: location)
            cell.mapView.delegate = self
        }
    }

    private func createNoCourseCell() -> UICollectionView.CellRegistration<
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

            cell.addCourseButton.addActionForOnce(
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

    private func createValueCell() -> UICollectionView.CellRegistration<
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

    private func createCourseCell() -> UICollectionView.CellRegistration<
        CourseCollectionViewCell,
        Entity.Course
    > {
        .init(
            cellNib: .init(
                nibName: CourseCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, course in

            guard let self = self else { return }

            cell.configure(course: course, parentVc: self)
        }
    }

    private func createNoImageCell() -> UICollectionView.CellRegistration<
        NoImageCollectionViewCell,
        Dummy
    > {
        .init { _, _, _ in }
    }
}
