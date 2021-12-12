import Combine
import UIKit

class CourseConfirmViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var viewModel: CourseConfirmViewModel!
    var router: CourseConfirmRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseConfirmViewModel
    ) -> CourseConfirmViewController {
        let instance = CourseConfirmViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDefaultConfiguration()
        self.setupNavigationBar()
        self.bindViewModelToView()
        self.configureSections()
    }

    private func setupNavigationBar() {
        navigationItem.title = "登録内容を確認"
    }

    private func bindViewModelToView() {
        self.viewModel.output.$imageUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUploadStateSink)
            .store(in: &self.bindings)

        self.viewModel.output.$courseUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseUploadStateSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        if case let .create(rock) = self.viewModel.registerType {
            snapShot.appendSections([.rock])
            snapShot.appendItems(
                [.rock(rockName: rock.name, headerUrl: rock.headerUrl)],
                toSection: .rock
            )
        }
        self.snapShot.appendSections(SectionLayoutKind.allCases.filter { $0 != .rock })
        self.snapShot.appendItems([.courseName(self.viewModel.course.name)], toSection: .courseName)
        self.snapShot.appendItems([.desc(self.viewModel.course.desc)], toSection: .desc)
        self.snapShot.appendItems([.grade(self.viewModel.course.grade)], toSection: .grade)
        self.snapShot.appendItems([.shape(self.viewModel.course.shape)], toSection: .shape)
        self.snapShot.appendItems([.header(self.viewModel.header)], toSection: .header)
        self.snapShot.appendItems(
            self.viewModel.images.filter { !$0.shouldDelete }.map { ItemKind.images($0) },
            toSection: .images
        )
        self.snapShot.appendItems([.register], toSection: .register)
        self.datasource.apply(self.snapShot)
    }
}

extension CourseConfirmViewController {

    private var courseUploadStateSink: (LoadingState<Void>) -> Void {{ [weak self] state in

        guard let self = self else { return }

        switch state {
            case .stanby: break

            case .loading:
                self.showIndicatorView()

            case .finish:
                self.viewModel.input.uploadImageSubject.send(())

            case let .failure(error):
                self.hideIndicatorView()
                self.showOKAlert(
                    title: "課題の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }}

    private var imageUploadStateSink: (LoadingState<Void>) -> Void {{ [weak self] state in

        guard let self = self else { return }

        switch state {
            case .stanby: break

            case .loading:
                self.showIndicatorView()

            case .finish:
                self.hideIndicatorView()
                self.router.route(to: .dismiss, from: self)

            case let .failure(error):
                self.hideIndicatorView()
                self.showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                ) { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .dismiss, from: self)
                }
        }
    }}
}

extension CourseConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }
}
