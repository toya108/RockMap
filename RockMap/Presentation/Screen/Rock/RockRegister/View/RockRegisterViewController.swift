//
//  RockRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit
import Combine
import PhotosUI

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
        
        configureCollectionView()
        setupPickerManager()
        setupNavigationBar()
        bindViewModelToView()
        configureSections()
    }

    private func setupPickerManager() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        pickerManager = PickerManager(
            from: self,
            configuration: configuration
        )
        pickerManager.delegate = self
    }

    private func setupNavigationBar() {
        navigationItem.title = "岩を\(viewModel.registerType.name)する"
        navigationItem.setRightBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .rockSearch, from: self)
                }
            ),
            animated: true
        )
    }
    
    private func bindViewModelToView() {
        viewModel.output.$rockLocation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: locationSink)
            .store(in: &bindings)

        viewModel.output.$seasons
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: seasonsSink)
            .store(in: &bindings)

        viewModel.output.$images
            .drop { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imagesSink)
            .store(in: &bindings)

        viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: headerSink)
            .store(in: &bindings)
        
        viewModel.output.$rockNameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockNameValidationSink)
            .store(in: &bindings)
        
        viewModel.output.$rockImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockImageValidationSink)
            .store(in: &bindings)

        viewModel.output.$headerImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerImageValidationSink)
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        let seasonItems = Entity.Rock.Season.allCases.map {
            ItemKind.season(season: $0, isSelecting: viewModel.output.seasons.contains($0))
        }
        snapShot.appendItems(seasonItems, toSection: .season)
        snapShot.appendItems([.lithology(viewModel.output.lithology)], toSection: .lithology)
        datasource.apply(snapShot)
    }
}

extension RockRegisterViewController {

    private func locationSink(_ location: LocationManager.LocationStructure) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .location))
        snapShot.appendItems([.location(location)], toSection: .location)
        datasource.apply(snapShot)
    }

    private func seasonsSink(_ seasons: Set<Entity.Rock.Season>) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .season))
        let items = Entity.Rock.Season.allCases.map {
            ItemKind.season(season: $0, isSelecting: seasons.contains($0))
        }
        snapShot.appendItems(items, toSection: .season)
        datasource.apply(snapShot)
    }

    private func headerSink(_ crudableImage: CrudableImageV2) {

        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .header))

        let shouldAppend = crudableImage.updateData != nil
            || crudableImage.image.url != nil
            && !crudableImage.shouldDelete

        snapShot.appendItems(
            [shouldAppend ? .header(crudableImage) : .noImage(.header)],
            toSection: .header
        )
        datasource.apply(snapShot)

        hideIndicatorView()
    }

    private func imagesSink(_ crudableImages: [CrudableImageV2]) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .images))
        snapShot.appendItems([.noImage(.normal)], toSection: .images)

        let items = crudableImages.filter { !$0.shouldDelete } .map { ItemKind.images($0) }
        snapShot.appendItems(items, toSection: .images)
        datasource.apply(snapShot)

        hideIndicatorView()
    }

    private func rockNameValidationSink(_ result: ValidationResult) {
        switch result {
            case .valid, .none:
                let items = snapShot.itemIdentifiers(inSection: .name)

                guard
                    let item = items.first(where: { $0.isErrorItem })
                else {
                    return
                }

                self.snapShot.deleteItems([item])

            case let .invalid(error):
                let items = snapShot.itemIdentifiers(inSection: .name)

                if let item = items.first(where: { $0.isErrorItem }) {
                    snapShot.deleteItems([item])
                }

                snapShot.appendItems([.error(error)], toSection: .name)
        }
        datasource.apply(snapShot)
    }

    private func rockImageValidationSink(_ result: ValidationResult) {

        let items = snapShot.itemIdentifiers(inSection: .confirmation)

        switch result {
            case .valid, .none:
                guard
                    let item = items.first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) })
                else {
                    return
                }

                snapShot.deleteItems([item])

            case let .invalid(error):
                if let item = items.first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) }) {
                    snapShot.deleteItems([item])
                }

                snapShot.appendItems([.error(error)], toSection: .confirmation)
        }
        datasource.apply(snapShot)
    }

    private func headerImageValidationSink(_ result: ValidationResult) {
        let items = snapShot.itemIdentifiers(inSection: .confirmation)

        switch result {
            case .valid, .none:
                guard
                    let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) })
                else {
                    return
                }

                snapShot.deleteItems([item])

            case let .invalid(error):
                if let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) }) {
                    snapShot.deleteItems([item])
                }
                snapShot.appendItems([.error(error)], toSection: .confirmation)
        }

        datasource.apply(snapShot)
    }
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
                viewModel.input.selectSeasonSubject.send(season)

            default:
                break
        }
    }
}

extension RockRegisterViewController: PickerManagerDelegate {

    func beganResultHandling() {
        showIndicatorView()
    }

    func didReceivePicking(data: Data, imageType: ImageType) {
        viewModel.input.setImageSubject.send((imageType, data: data))
    }

}

