import Combine
import UIKit

class RockConfirmViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var viewModel: RockConfirmViewModel!
    var router: RockConfirmRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: RockConfirmViewModel
    ) -> RockConfirmViewController {
        let instance = RockConfirmViewController()
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

        self.viewModel.output.$rockUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockUploadStateSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionLayoutKind.allCases)
        self.snapShot.appendItems([.name(self.viewModel.rockEntity.name)], toSection: .name)
        self.snapShot.appendItems([.desc(self.viewModel.rockEntity.desc)], toSection: .desc)
        self.snapShot.appendItems([.erea(self.viewModel.rockEntity.erea ?? "なし")], toSection: .erea)
        self.snapShot.appendItems([.season(self.viewModel.rockEntity.seasons)], toSection: .season)
        self.snapShot.appendItems(
            [.lithology(self.viewModel.rockEntity.lithology)],
            toSection: .lithology
        )
        let location = LocationManager.LocationStructure(
            location: .init(
                latitude: self.viewModel.rockEntity.location.latitude,
                longitude: self.viewModel.rockEntity.location.longitude
            ),
            address: self.viewModel.rockEntity.address,
            prefecture: self.viewModel.rockEntity.prefecture
        )
        self.snapShot.appendItems([.location(location)], toSection: .location)
        self.snapShot.appendItems([.header(self.viewModel.header)], toSection: .header)
        self.snapShot.appendItems(
            self.viewModel.images.filter { !$0.shouldDelete }.map { ItemKind.images($0) },
            toSection: .images
        )
        self.snapShot.appendItems([.register], toSection: .register)
        self.datasource.apply(self.snapShot)
    }
}

extension RockConfirmViewController {
    
    private var rockUploadStateSink: (LoadingState<Void>) -> Void {{ [weak self] state in

        guard let self = self else { return }

        switch state {
        case .standby: break

        case .loading:
            self.showIndicatorView()

        case .finish:
            self.viewModel.input.uploadImageSubject.send()

        case let .failure(error):
            self.hideIndicatorView()
            self.showOKAlert(
                title: "岩の登録に失敗しました",
                message: error?.localizedDescription ?? ""
            )
        }
    }}

    private var imageUploadStateSink: (LoadingState<Void>) -> Void {{ [weak self] state in

        guard let self = self else { return }

        switch state {
        case .standby: break

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

extension RockConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }
}
