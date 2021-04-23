//
//  MyPageDatasourse.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import UIKit

extension MyPageViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {

        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case let .headerImage(reference):
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureHeaderImageCell(),
                        for: indexPath,
                        item: reference
                    )

                case .user:
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureUserCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .socialLink(socialLinkType):
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureSocialLinkCell(),
                        for: indexPath,
                        item: socialLinkType
                    )

                case .introduction:
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureIntroductionCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case .climbedNumber:
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureClimbedNumberCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case .registeredRock(let kind), .registeredCourse(let kind):
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureListCell(),
                        for: indexPath,
                        item: kind
                    )

                case .noCourse:
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureNoCourseCell(),
                        for: indexPath,
                        item: Dummy()
                    )

                case let .climbedCourse(course):
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureCoursesCell(),
                        for: indexPath,
                        item: course
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

    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
        }
    }

    private func configureUserCell() -> UICollectionView.CellRegistration<
        UserCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: UserCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.userView.configure(
                prefix: "",
                userName: self.viewModel.output.user?.name ?? "-",
                photoURL: self.viewModel.output.user?.photoURL,
                registeredDate: self.viewModel.output.user?.createdAt
            )
        }
    }

    private func configureSocialLinkCell() -> UICollectionView.CellRegistration<
        SocialLinkCollectionViewCell,
        FIDocument.User.SocialLinkType
    > {
        .init { cell, _, socialLinkType in
            cell.configure(for: socialLinkType)
        }
    }

    private func configureIntroductionCell() -> UICollectionView.CellRegistration<
        LabelCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.label.text = self.viewModel.output.user?.introduction
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
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                total: self.viewModel.output.climbedList.count,
                flash: self.viewModel.output.climbedList.filter(\.type.isFlash).count,
                redPoint: self.viewModel.output.climbedList.filter(\.type.isRedpoint).count
            )
        }
    }

    private func configureListCell() -> UICollectionView.CellRegistration<
        UICollectionViewListCell,
        ItemKind.RegisteredKind
    > {
        .init { cell, _, kind in
            var content = cell.defaultContentConfiguration()
            content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
            content.imageProperties.tintColor = .black
            content.image = kind.iconImage
            content.text = kind.cellTitle
            cell.contentConfiguration = content
        }
    }

    private func configureNoCourseCell() -> UICollectionView.CellRegistration<
        NoCoursesCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: NoCoursesCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, _ in
            cell.titleLabel.text = "まだ登った課題はありません。"
            cell.addCourseButton.isHidden = true
        }
    }

    private func configureCoursesCell() -> UICollectionView.CellRegistration<
        CourseCollectionViewCell,
        FIDocument.Course
    > {
        .init(
            cellNib: .init(
                nibName: CourseCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, course in
            cell.configure(course: course)
        }
    }
}
