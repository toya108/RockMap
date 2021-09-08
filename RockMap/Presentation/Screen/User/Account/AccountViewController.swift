
import Auth
import Combine
import UIKit

class AccountViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()
    private let deleteUserUsecase = Usecase.User.Delete()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupBindings()
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
        navigationItem.title = "アカウント設定"
    }

    private func setupBindings() {
        AuthManager.shared.loginFinishedPublisher
            .sink { [weak self] result in

                guard let self = self else { return }

                switch result {
                case .success:
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                        .rootViewController = MainTabBarController()

                case let .failure(error):
                    self.showOKAlert(
                        title: "ログインに失敗しました",
                        message: "通信環境をご確認の上、再度お試し下さい。\(error.localizedDescription)"
                    )
                }
            }
            .store(in: &self.bindings)
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
            AuthManager.shared.isLoggedIn ? self.logout() : self.login()

        case .deleteUser:
            let deleteAction = UIAlertAction(
                title: "削除",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                self.showIndicatorView()

                self.deleteUserUsecase.delete(id: AuthManager.shared.uid)
                    .catch { [weak self] error -> Empty in

                        guard let self = self else { return Empty() }

                        self.hideIndicatorView()
                        self.showOKAlert(
                            title: "アカウントの削除に失敗しました。",
                            message: error.localizedDescription
                        )
                        return Empty()
                    }
                    .sink { [weak self] _ in

                        guard let self = self else { return }

                        self.hideIndicatorView()

                        guard
                            let vc = UIStoryboard(
                                name: LoginViewController.className,
                                bundle: nil
                            ).instantiateInitialViewController() as? LoginViewController
                        else {
                            assertionFailure()
                            return
                        }

                        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                            .rootViewController = vc
                    }
                    .store(in: &self.bindings)
            }

            showAlert(
                title: "アカウントを削除しますか？",
                message: "アカウントを削除しても登録した岩と課題は無くなりません。",
                actions: [
                    deleteAction,
                    .init(title: "Cancel", style: .cancel)
                ],
                style: .alert
            )

        default:
            break
        }
    }

    private func logout() {
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { [weak self] _ in

            guard let self = self else { return }

            AuthManager.shared.logout()
                .catch { [weak self] error -> Empty in

                    guard let self = self else { return Empty() }

                    self.showOKAlert(
                        title: "ログアウトに失敗しました",
                        message: error.localizedDescription
                    )
                    return Empty()
                }
                .sink { _ in
                    guard
                        let vc = UIStoryboard(
                            name: LoginViewController.className,
                            bundle: nil
                        ).instantiateInitialViewController() as? LoginViewController
                    else {
                        assertionFailure()
                        return
                    }

                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                        .rootViewController = vc
                }
                .store(in: &self.bindings)
        }

        showAlert(
            title: "ログアウトしますか？",
            message: "ログアウトするとアプリの最初の画面に戻ります。",
            actions: [
                okAction,
                .init(title: "Cancel", style: .cancel)
            ],
            style: .alert
        )
    }

    private func login() {
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { [weak self] _ in

                guard let self = self else { return }

                guard
                    let authViewController = AuthManager.shared.authViewController
                else {
                    return
                }

                let vc = RockMapNavigationController(
                    rootVC: authViewController,
                    naviBarClass: RockMapNavigationBar.self
                )
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            }
        )

        showAlert(
            title: "ログインしますか？",
            message: "ログインするとアプリの最初の画面に戻ります。",
            actions: [
                okAction,
                .init(title: "Cancel", style: .cancel)
            ],
            style: .alert
        )
    }
}

extension AccountViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] _, indexPath, item in

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
                cell.isUserInteractionEnabled = item.tapEnabled
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

            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section]
                .headerTitle
            supplementaryView.label.font = UIFont.preferredFont(forTextStyle: .caption1)
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
