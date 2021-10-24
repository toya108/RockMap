import Combine
import PhotosUI
import UIKit

class CourseRegisterViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var viewModel: CourseRegisterViewModel!
    var router: CourseRegisterRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    var bindings = Set<AnyCancellable>()

    var pickerManager: PickerManager!

    static func createInstance(
        viewModel: CourseRegisterViewModel
    ) -> CourseRegisterViewController {
        let instance = CourseRegisterViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        self.setupPickerManager()
        self.setupNavigationBar()
        self.bindViewModelToView()
        self.configureSections()
    }

    private func setupPickerManager() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        self.pickerManager = PickerManager(
            from: self,
            configuration: configuration
        )
        self.pickerManager.delegate = self
    }

    private func setupNavigationBar() {
        navigationItem.title = "課題を\(self.viewModel.registerType.name)する"

        navigationItem.setRightBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .rockDetail, from: self)
                }
            ),
            animated: false
        )
    }

    private func bindViewModelToView() {
        self.viewModel.output.$grade
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: gradeSink)
            .store(in: &self.bindings)

        self.viewModel.output.$shapes
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: shapeSink)
            .store(in: &self.bindings)

        self.viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerSink)
            .store(in: &self.bindings)

        self.viewModel.output.$images
            .drop { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imagesSink)
            .store(in: &self.bindings)

        self.viewModel.output.$courseNameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseNameValidationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$courseImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseImageValidationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$headerImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerImageValidationSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        if case .create = self.viewModel.registerType {
            snapShot.appendSections([.rock])
            snapShot.appendItems([.rock], toSection: .rock)
        }

        self.snapShot.appendSections(SectionLayoutKind.allCases.filter { $0 != .rock })

        SectionLayoutKind.allCases.filter { $0 != .rock }.forEach {
            snapShot.appendItems($0.initalItems, toSection: $0)
        }
        let shapeItems = Entity.Course.Shape.allCases.map {
            ItemKind.shape(shape: $0, isSelecting: viewModel.output.shapes.contains($0))
        }
        self.snapShot.appendItems(shapeItems, toSection: .shape)
        self.datasource.apply(self.snapShot)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CourseRegisterViewController: PickerManagerDelegate {
    func beganResultHandling() {
        showIndicatorView()
    }

    func didReceivePicking(
        data: Data,
        imageType: Entity.Image.ImageType
    ) {
        self.viewModel.input.setImageSubject.send((data, imageType))
    }
}

extension CourseRegisterViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }

        switch item {
        case let .shape(shape, _):
            self.viewModel.input.shapeSubject.send([shape])

        default:
            break
        }
    }
}

extension CourseRegisterViewController {

    private var gradeSink: (Entity.Course.Grade) -> Void {{ [weak self] grade in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .grade))
        self.snapShot.appendItems([.grade(grade)], toSection: .grade)
        self.datasource.apply(self.snapShot)
    }}

    private var shapeSink: (Set<Entity.Course.Shape>) -> Void {{ [weak self] shapes in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .shape))
        let items = Entity.Course.Shape.allCases.map {
            ItemKind.shape(shape: $0, isSelecting: shapes.contains($0))
        }
        self.snapShot.appendItems(items, toSection: .shape)
        self.datasource.apply(self.snapShot)
    }}

    private var headerSink: (CrudableImage) -> Void {{ [weak self] crudableImage in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .header))

        let shouldAppend = crudableImage.updateData != nil
            || crudableImage.image.url != nil
            && !crudableImage.shouldDelete

        self.snapShot.appendItems(
            [shouldAppend ? .header(crudableImage) : .noImage(.header)],
            toSection: .header
        )
        self.datasource.apply(self.snapShot)

        self.hideIndicatorView()
    }}

    private var imagesSink: ([CrudableImage]) -> Void {{ [weak self] crudableImages in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
        self.snapShot.appendItems([.noImage(.normal)], toSection: .images)

        let items = crudableImages.filter { !$0.shouldDelete }.map { ItemKind.images($0) }
        self.snapShot.appendItems(items, toSection: .images)
        self.datasource.apply(self.snapShot)

        self.hideIndicatorView()
    }}

    private var courseNameValidationSink: (ValidationResult) -> Void {{ [weak self] result in

        guard let self = self else { return }

        switch result {
        case .valid, .none:
            let items = self.snapShot.itemIdentifiers(inSection: .courseName)

            guard
                let item = items.first(where: { $0.isErrorItem })
            else {
                return
            }

            self.snapShot.deleteItems([item])

        case let .invalid(error):
            let items = self.snapShot.itemIdentifiers(inSection: .courseName)

            if let item = items.first(where: { $0.isErrorItem }) {
                self.snapShot.deleteItems([item])
            }

            self.snapShot.appendItems([.error(error)], toSection: .courseName)
        }
        self.datasource.apply(self.snapShot)
    }}

    private var courseImageValidationSink: (ValidationResult) -> Void {{ [weak self] result in

        guard let self = self else { return }

        let items = self.snapShot.itemIdentifiers(inSection: .confirmation)

        switch result {
        case .valid, .none:
            guard
                let item = items
                    .first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) })
            else {
                return
            }

            self.snapShot.deleteItems([item])

        case let .invalid(error):
            if let item = items.first(
                where: { $0 == .error(.quantity(formName: "画像", max: 10)) }
            ) {
                self.snapShot.deleteItems([item])
            }

            self.snapShot.appendItems([.error(error)], toSection: .confirmation)
        }
        self.datasource.apply(self.snapShot)
    }}

    private var headerImageValidationSink: (ValidationResult) -> Void {{ [weak self] result in

        guard let self = self else { return }

        let items = self.snapShot.itemIdentifiers(inSection: .confirmation)

        switch result {
        case .valid, .none:
            guard
                let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) })
            else {
                return
            }

            self.snapShot.deleteItems([item])

        case let .invalid(error):
            if let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) }) {
                self.snapShot.deleteItems([item])
            }
            self.snapShot.appendItems([.error(error)], toSection: .confirmation)
        }

        self.datasource.apply(self.snapShot)
    }}
}
