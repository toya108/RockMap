//
//  SettingsViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/31.
//

import UIKit

class SettingsViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        configureCollectionView()
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
        navigationItem.title = "設定"
        navigationItem.setRightBarButton(
            .init(
                title: nil,
                image: UIImage.SystemImages.xmark,
                primaryAction: .init { [weak self] _ in

                    guard let self = self else { return }

                    self.dismiss(animated: true)
                },
                menu: nil
            ),
            animated: true
        )
    }
}

extension SettingsViewController {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

}

extension SettingsViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            let registration = UICollectionView.CellRegistration<
                UICollectionViewListCell,
                Dummy
            > { cell, _, _ in
                var content = cell.defaultContentConfiguration()
                content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
                content.imageProperties.tintColor = .black
                content.image = item.iconImage
                content.text = item.title
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
