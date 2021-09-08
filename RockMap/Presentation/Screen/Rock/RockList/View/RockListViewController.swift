import Combine
import UIKit

class RockListViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    let emptyLabel = UILabel()
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!
    var viewModel: RockListViewModel!
    var router: RocklistRouter!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: RockListViewModel
    ) -> RockListViewController {
        let instance = RockListViewController()
        instance.viewModel = viewModel
        instance.router = .init(viewModel: viewModel)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubViews()
        self.setupNavigationBar()
        self.setupEmptyView()
        configureCollectionView(topInset: 16)
        self.setupSections()
        self.setupViewModelOutput()
    }

    private func setupSubViews() {
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupNavigationBar() {
        navigationItem.title = "登録した岩一覧"
    }

    private func setupEmptyView() {
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.emptyLabel)
        self.emptyLabel.text = "登録した岩が見つかりませんでした。"
        NSLayoutConstraint.activate([
            self.emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func setupSections() {
        self.snapShot.appendSections(SectionKind.allCases)
        if self.viewModel.isMine {
            self.snapShot.appendItems([.annotationHeader], toSection: .annotationHeader)
        }
        self.datasource.apply(self.snapShot)
    }

    private func setupViewModelOutput() {
        self.viewModel.output.$rocks
            .removeDuplicates()
            .drop(while: { $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rocksSink)
            .store(in: &self.bindings)

        self.viewModel.output.$isEmpty
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: isEmptySink)
            .store(in: &self.bindings)

        self.viewModel.output.$deleteState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: deleteStateSink)
            .store(in: &self.bindings)
    }
}

extension RockListViewController {
    private func rocksSink(_ courses: [Entity.Rock]) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .main))
        self.snapShot.appendItems(courses.map { ItemKind.rock($0) }, toSection: .main)
        self.datasource.apply(self.snapShot)
    }

    private func isEmptySink(_ isEmpty: Bool) {
        self.collectionView.isHidden = isEmpty
    }

    private func deleteStateSink(_ state: LoadingState<Void>) {
        switch state {
        case .loading:
            self.showIndicatorView()

        case .finish, .stanby:
            self.hideIndicatorView()

        case let .failure(error):
            self.hideIndicatorView()
            self.showOKAlert(
                title: "削除に失敗しました",
                message: error?.localizedDescription ?? ""
            )
        }
    }
}

extension RockListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let item = datasource.itemIdentifier(for: indexPath),
            case let .rock(rock) = item
        else {
            return
        }

        self.router.route(to: .rockDetail(rock), from: self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard self.viewModel.isMine else { return nil }

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { [weak self] _ in

            guard let self = self else { return nil }

            guard
                let item = self.datasource.itemIdentifier(for: indexPath),
                case let .rock(rock) = item
            else {
                return nil
            }

            return UIMenu(
                title: "",
                children: [
                    self.makeEditAction(rock: rock),
                    self.makeDeleteAction(rock: rock),
                ]
            )
        }

        return .init(
            identifier: nil,
            previewProvider: nil,
            actionProvider: actionProvider
        )
    }

    private func makeEditAction(rock: Entity.Rock) -> UIAction {
        .init(
            title: "編集",
            image: UIImage.SystemImages.squareAndPencil
        ) { [weak self] _ in

            guard let self = self else { return }

            self.router.route(to: .rockRegister(rock), from: self)
        }
    }

    private func makeDeleteAction(
        rock: Entity.Rock
    ) -> UIAction {
        .init(
            title: "削除",
            image: UIImage.SystemImages.trash,
            attributes: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }

            let deleteAction = UIAlertAction(
                title: "削除",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.input.deleteRockSubject.send(rock)
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

            self.showAlert(
                title: "登録した岩を削除します。",
                message: "削除した情報は復元できません。\n削除してもよろしいですか？",
                actions: [
                    deleteAction,
                    cancelAction,
                ],
                style: .actionSheet
            )
        }
    }
}

extension RockListViewController: RockRegisterDetectableViewControllerProtocol {
    func didRockRegisterFinished() {
        self.viewModel.fetchRockList()
    }
}
