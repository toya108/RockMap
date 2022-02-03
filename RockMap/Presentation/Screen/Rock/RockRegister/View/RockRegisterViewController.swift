import Combine
import PhotosUI
import UIKit

class RockRegisterViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var viewModel: RockRegisterViewModel!
    var router: RockRegisterRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    var bindings = Set<AnyCancellable>()

    var pickerManager: PickerManager!

    static func createInstance(
        viewModel: RockRegisterViewModel
    ) -> RockRegisterViewController {
        let instance = self.init()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDefaultConfiguration()
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
            delegate: self,
            configuration: configuration
        )
    }

    private func setupNavigationBar() {
        navigationItem.title = "岩を\(self.viewModel.registerType.name)する"
        let closeButton = UIBarButtonItem(
            image: Resources.Images.System.xmark.uiImage,
            primaryAction: .init { [weak self] _ in

                guard let self = self else { return }

                self.router.route(to: .map, from: self)
            }
        )
        closeButton.tintColor = .label
        navigationItem.setRightBarButton(closeButton, animated: true)
    }

    private func bindViewModelToView() {
        self.viewModel.output.$rockLocation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: locationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$seasons
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: seasonsSink)
            .store(in: &self.bindings)

        self.viewModel.output.$images
            .drop { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imagesSink)
            .store(in: &self.bindings)

        self.viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: headerSink)
            .store(in: &self.bindings)

        self.viewModel.output.$rockNameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockNameValidationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$rockImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockImageValidationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$headerImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerImageValidationSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        let seasonItems = Entity.Rock.Season.allCases.map {
            ItemKind.season(season: $0, isSelecting: viewModel.output.seasons.contains($0))
        }
        self.snapShot.appendItems(seasonItems, toSection: .season)
        self.snapShot.appendItems(
            [.lithology(self.viewModel.output.lithology)],
            toSection: .lithology
        )
        self.datasource.apply(self.snapShot)
    }
}

extension RockRegisterViewController {

    private var locationSink: (LocationManager.LocationStructure) -> Void {{ [weak self] location in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .location))
        self.snapShot.appendItems([.location(location)], toSection: .location)
        self.datasource.apply(self.snapShot)
    }}

    private var seasonsSink: (Set<Entity.Rock.Season>) -> Void {{ [weak self] seasons in

        guard let self = self else { return }

        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .season))
        let items = Entity.Rock.Season.allCases.map {
            ItemKind.season(season: $0, isSelecting: seasons.contains($0))
        }
        self.snapShot.appendItems(items, toSection: .season)
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

    private var rockNameValidationSink: (ValidationResult) -> Void {{ [weak self] result in

        guard let self = self else { return }

        switch result {
        case .valid, .none:
            let items = self.snapShot.itemIdentifiers(inSection: .name)

            guard
                let item = items.first(where: { $0.isErrorItem })
            else {
                return
            }

            self.snapShot.deleteItems([item])

        case let .invalid(error):
            let items = self.snapShot.itemIdentifiers(inSection: .name)

            if let item = items.first(where: { $0.isErrorItem }) {
                self.snapShot.deleteItems([item])
            }

            self.snapShot.appendItems([.error(error)], toSection: .name)
        }
        self.datasource.apply(self.snapShot)
    }}

    private var rockImageValidationSink: (ValidationResult) -> Void {{ [weak self] result in

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
            if
                let item = items
                    .first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) }) {
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

extension RockRegisterViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }

        switch item {
        case let .season(season, _):
            self.viewModel.input.selectSeasonSubject.send(season)

        default:
            break
        }
    }
}

extension RockRegisterViewController: PickerManagerDelegate {
    func startPicking() {
        showIndicatorView()
    }

    func didReceive(data: Data, imageType: Entity.Image.ImageType) {
        self.viewModel.input.setImageSubject.send((imageType, data: data))
    }

    func didReceive(error: Error) {
        DispatchQueue.main.async {
            self.showOKAlert(
                title: "画像の取得に失敗しました。",
                message: "reason: \(error.localizedDescription)"
            )
            self.hideIndicatorView()
        }
    }
}

extension RockRegisterViewController: LocationSelectDelegate {
    func didFinishSelectLocation(location: CLLocation, address: String) {
        viewModel.input.locationSubject.send(
            .init(location: location, address: address)
        )
    }
}
