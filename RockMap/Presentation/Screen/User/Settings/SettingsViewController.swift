import SafariServices
import StoreKit
import UIKit

class SettingsViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        configureCollectionView(topInset: 16)
        self.configureSections()
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionKind.allCases)
        SectionKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        self.datasource.apply(self.snapShot)
    }

    private func setupNavigationBar() {
        navigationItem.title = "設定"
        let closeButton = UIBarButtonItem(
            title: nil,
            image: UIImage.SystemImages.xmark,
            primaryAction: .init { [weak self] _ in

                guard let self = self else { return }

                self.dismiss(animated: true)
            },
            menu: nil
        )
        closeButton.tintColor = .label
        navigationItem.setRightBarButton(closeButton, animated: true)
    }
}

extension SettingsViewController {
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
        case .account:
            navigationController?.pushViewController(
                AccountViewController(),
                animated: true
            )

        case .privacyPolicy:
            let vc = SFSafariViewController(url: Resources.Const.Url.privacyPolicy)
            navigationController?.present(vc, animated: true)

        case .terms:
            let vc = SFSafariViewController(url: Resources.Const.Url.terms)
            navigationController?.present(vc, animated: true)

        case .review:
            guard
                let scene = UIApplication.shared.connectedScenes.first(
                    where: { $0.activationState == .foregroundActive }
                ) as? UIWindowScene
            else {
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

extension SettingsViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {

        let registration = UICollectionView.CellRegistration<
            UICollectionViewListCell,
            ItemKind
        > { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
            content.imageProperties.tintColor = .black
            content.image = item.iconImage
            content.text = item.title
            cell.contentConfiguration = content
        }

        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section]
                .headerTitle
            supplementaryView.label.font = UIFont.preferredFont(forTextStyle: .caption1)
        }

        datasource.supplementaryViewProvider = { collectionView, _, index in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }

        return datasource
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =
            UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

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
