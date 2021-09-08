
import Auth
import Combine
import UIKit

class MyPageViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var viewModel: MyPageViewModel!
    var router: MyPageRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    private let refreshControl = UIRefreshControl()

    static func createInstance(
        viewModel: MyPageViewModel
    ) -> MyPageViewController {
        let instance = MyPageViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        configureCollectionView()
        self.configureSections()
        self.bindViewModelOutput()
        self.setupRefreshControl()
    }

    private func setupRefreshControl() {
        self.collectionView.refreshControl = self.refreshControl
        self.refreshControl.addAction(
            .init { [weak self] _ in
                self?.viewModel.fetchUser()
                self?.refreshControl.endRefreshing()
            },
            for: .valueChanged
        )
    }

    private func setupNavigationBar() {
        switch self.viewModel.userKind {
        case .mine, .guest:
            navigationItem.title = "マイページ"
            navigationItem.setRightBarButton(
                .init(
                    title: nil,
                    image: UIImage.SystemImages.gear,
                    primaryAction: .init { [weak self] _ in

                        guard let self = self else { return }

                        self.router.route(to: .settings, from: self)
                    },
                    menu: nil
                ),
                animated: true
            )

        case .other:
            navigationItem.title = self.viewModel.output.fetchUserState.content?.name ?? ""
        }
    }

    private func bindViewModelOutput() {
        self.viewModel.output.$fetchUserState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: userSink)
            .store(in: &self.bindings)

        self.viewModel.output
            .$climbedList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: climbedListSink)
            .store(in: &self.bindings)

        self.viewModel.output
            .$recentClimbedCourses
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: recentClimbedCoursesSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionKind.allCases)
        SectionKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        self.datasource.apply(self.snapShot) { [weak self] in
            self?.viewModel.input.finishedCollectionViewSetup.send()
        }
    }
}

extension MyPageViewController {
    private func userSink(_ user: LoadingState<Entity.User>) {
        self.snapShot.reloadSections([.user, .socialLink])
        self.datasource.apply(self.snapShot, animatingDifferences: false)
    }

    private func climbedListSink(_ climbedList: [Entity.ClimbRecord]) {
        self.snapShot.reloadSections([.climbedNumber])
        self.datasource.apply(self.snapShot, animatingDifferences: false)
    }

    private func recentClimbedCoursesSink(_ courses: [Entity.Course]) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .recentClimbedCourses))

        if courses.isEmpty {
            self.snapShot.appendItems([.noCourse], toSection: .recentClimbedCourses)
        } else {
            self.snapShot.appendItems(
                courses.map { ItemKind.climbedCourse($0) },
                toSection: .recentClimbedCourses
            )
        }
        self.datasource.apply(self.snapShot, animatingDifferences: false)
    }
}

extension MyPageViewController {
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
        case .climbedNumber:
            self.router.route(to: .climbedCourseList, from: self)

        case let .climbedCourse(course):
            self.router.route(to: .courseDetail(course), from: self)

        case .registeredRock:
            self.router.route(
                to: .rockList,
                from: self
            )

        case .registeredCourse:
            self.router.route(
                to: .courseList,
                from: self
            )

        default:
            break
        }
    }
}
