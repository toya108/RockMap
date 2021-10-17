import Combine
import UIKit

class CourseListViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    let emptyLabel = UILabel()
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!
    var viewModel: CourseListViewModel!
    var router: CourselistRouter!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseListViewModel
    ) -> CourseListViewController {
        let instance = CourseListViewController()
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
        navigationItem.title = "登録した課題一覧"
    }

    private func setupEmptyView() {
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.emptyLabel)
        self.emptyLabel.text = "課題が見つかりませんでした。"
        NSLayoutConstraint.activate([
            self.emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        self.viewModel.output.$courses
            .removeDuplicates()
            .drop(while: { $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: coursesSink)
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

    private func setupNotification() {
        NotificationCenter.default.publisher(for: .didCourseRegisterFinished)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.fetchCourseList()
            }
            .store(in: &bindings)
    }
}

extension CourseListViewController {
    private func coursesSink(_ courses: [Entity.Course]) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .main))
        self.snapShot.appendItems(courses.map { ItemKind.course($0) }, toSection: .main)
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

extension CourseListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let item = datasource.itemIdentifier(for: indexPath),
            case let .course(course) = item
        else {
            return
        }

        self.router.route(to: .courseDetail(course), from: self)
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
                case let .course(course) = item
            else {
                return nil
            }

            return UIMenu(
                title: "",
                children: [
                    self.makeEditAction(course: course),
                    self.makeDeleteAction(course: course)
                ]
            )
        }

        return .init(
            identifier: nil,
            previewProvider: nil,
            actionProvider: actionProvider
        )
    }

    private func makeEditAction(course: Entity.Course) -> UIAction {
        .init(
            title: "編集",
            image: UIImage.SystemImages.squareAndPencil
        ) { [weak self] _ in

            guard let self = self else { return }

            self.router.route(to: .courseRegister(course), from: self)
        }
    }

    private func makeDeleteAction(
        course: Entity.Course
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

                self.viewModel.input.deleteCourseSubject.send(course)
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

            self.showAlert(
                title: "課題を削除します。",
                message: "削除した課題は復元できません。\n削除してもよろしいですか？",
                actions: [
                    deleteAction,
                    cancelAction
                ],
                style: .actionSheet
            )
        }
    }
}
