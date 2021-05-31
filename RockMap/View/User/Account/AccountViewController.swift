//
//  AccountViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/06/01.
//

import UIKit

class AccountViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        configureCollectionView(topInset: 16)
        configureSections()
    }

    private func configureSections() {
        snapShot.appendSections(SectionKind.allCases)
        SectionKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        datasource.apply(snapShot)
    }

    private func setupNavigationBar() {
        navigationItem.title = "アカウント設定"
    }
}

extension AccountViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }

        switch item {
            case .loginOrLogout:
                break

            case .deleteUser:
                break

            default:
                break
        }
    }

}

extension AccountViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            let registration = UICollectionView.CellRegistration<
                UICollectionViewListCell,
                Dummy
            > { cell, _, _ in
                var content = UIListContentConfiguration.valueCell()
                content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
                content.imageProperties.tintColor = .black
                content.text = item.title
                if let secondaryText = item.secondaryText {
                    content.secondaryText = secondaryText
                }
                cell.contentConfiguration = content
            }

            return self.collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: Dummy()
            )
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section].headerTitle
            supplementaryView.label.font = UIFont.preferredFont(forTextStyle: .caption1)
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

    func createLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

            let sectionType = SectionKind.allCases[sectionNumber]

            let section = NSCollectionLayoutSection.list(
                using: .init(appearance: .insetGrouped),
                layoutEnvironment: env
            )

            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(24)
                ),
                elementKind: sectionType.headerIdentifer,
                alignment: .top
            )

            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }

        return layout
    }

}
