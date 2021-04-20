//
//  MyPageDatasourse.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import UIKit

extension MyPageViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
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
                userName: self.viewModel.user?.name ?? "-",
                photoURL: self.viewModel.user?.photoURL,
                registeredDate: self.viewModel.user?.createdAt
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

            cell.label.text = self.viewModel.user?.introduction
        }
    }
}
