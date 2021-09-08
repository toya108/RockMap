import Combine
import UIKit

class CourseDetailViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    var viewModel: CourseDetailViewModel!
    var router: CourseDetailRouter!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseDetailViewModel
    ) -> CourseDetailViewController {
        let instance = CourseDetailViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        configureCollectionView()
        self.bindViewToViewModel()
        self.configureSections()
    }

    private func setupNavigationBar() {
        guard
            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
        else {
            return
        }

        rockMapNavigationBar.setup()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func bindViewToViewModel() {
        self.viewModel.output.$fetchParentRockState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchParentRockStateSink)
            .store(in: &self.bindings)

        self.viewModel.output.$fetchRegisteredUserState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchRegisteredUserStateSink)
            .store(in: &self.bindings)

        self.viewModel.output.$totalClimbedNumber
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: totalClimbedNumberSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        if let url = viewModel.course.headerUrl {
            self.snapShot.appendItems([.headerImage(url)], toSection: .headerImage)
        }
        let valueCellData = ValueCollectionViewCell.ValueCellStructure(
            image: UIImage.SystemImages.triangleLefthalfFill,
            title: "形状",
            subTitle: self.viewModel.course.shape.map(\.name).joined(separator: "/")
        )
        self.snapShot.appendItems([.shape(valueCellData)], toSection: .info)

        let images = self.viewModel.course.imageUrls
        if images.isEmpty {
            self.snapShot.appendItems([.noImage], toSection: .images)
        } else {
            self.snapShot.appendItems(images.map { ItemKind.image($0) }, toSection: .images)
        }
        self.datasource.apply(self.snapShot) { [weak self] in
            self?.viewModel.input.finishedCollectionViewSetup.send()
        }
    }
}

extension CourseDetailViewController {
    private func fetchParentRockStateSink(_ state: LoadingState<Entity.Rock>) {
        switch state {
        case .stanby, .failure, .loading:
            break

        case .finish:
            self.snapShot.deleteItems([.parentRock])
            self.snapShot.appendItems([.parentRock], toSection: .parentRock)
            self.datasource.apply(self.snapShot, animatingDifferences: false)
        }
    }

    private func fetchRegisteredUserStateSink(_ state: LoadingState<Entity.User>) {
        switch state {
        case .stanby, .failure, .loading:
            break

        case .finish:
            self.snapShot.deleteItems([.registeredUser])
            self.snapShot.appendItems([.registeredUser], toSection: .registeredUser)
            self.datasource.apply(self.snapShot, animatingDifferences: false)
        }
    }

    private func totalClimbedNumberSink(_ state: Entity.TotalClimbedNumber?) {
        self.snapShot.reloadSections([.climbedNumber])
        self.datasource.apply(self.snapShot, animatingDifferences: false)
    }
}

extension CourseDetailViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = self.datasource.itemIdentifier(for: indexPath)

        switch item {
        case .climbedNumber:
            self.router.route(to: .climbedUserList, from: self)

        default:
            break
        }
    }
}
