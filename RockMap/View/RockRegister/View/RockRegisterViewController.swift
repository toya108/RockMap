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

    private var bindings = Set<AnyCancellable>()

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
        navigationItem.title = "岩を登録する"
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
        viewModel.$rockImageDatas
            .drop { $0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                
                defer {
                    self?.hideIndicatorView()
                }
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
                
                self.snapShot.appendItems([.noImage(.normal)], toSection: .images)
                
                let items = images.map { ItemKind.images($0) }
                self.snapShot.appendItems(items, toSection: .images)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$rockHeaderImage
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] data in

                defer {
                    self?.hideIndicatorView()
                }

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .headerImage))

                if let data = data {
                    self.snapShot.appendItems([.headerImage(data)], toSection: .headerImage)

                } else {
                    self.snapShot.appendItems([.noImage(.header)], toSection: .headerImage)

                }

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$rockNameValidationResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                
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
            }
            .store(in: &bindings)
        
        viewModel.$rockImageValidationResult
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                
                guard let self = self else { return }

                let items = self.snapShot.itemIdentifiers(inSection: .confirmation)

                switch result {
                case .valid, .none:
                    guard
                        let item = items.first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) })
                    else {
                        return
                    }

                    self.snapShot.deleteItems([item])

                case let .invalid(error):
                    if let item = items.first(where: { $0 == .error(.quantity(formName: "画像", max: 10)) }) {
                        self.snapShot.deleteItems([item])
                    }

                    self.snapShot.appendItems([.error(error)], toSection: .confirmation)
                }
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$headerImageValidationResult
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in

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
            }
            .store(in: &bindings)
        
        viewModel.$rockLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] locationStructure in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .location))
                
                self.snapShot.appendItems([.location(locationStructure)], toSection: .location)
 
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$seasons
            .receive(on: RunLoop.main)
            .sink { [weak self] seasons in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .season))
                
                let items = FIDocument.Rock.Season.allCases.map { ItemKind.season(season: $0, isSelecting: seasons.contains($0)) }
                self.snapShot.appendItems(items, toSection: .season)
 
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        let seasonItems = FIDocument.Rock.Season.allCases.map {
            ItemKind.season(season: $0, isSelecting: viewModel.seasons.contains($0))
        }
        snapShot.appendItems(seasonItems, toSection: .season)
        snapShot.appendItems([.lithology(viewModel.lithology)], toSection: .lithology)
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

                if viewModel.seasons.contains(season) {
                    viewModel.seasons.remove(season)
                } else {
                    viewModel.seasons.insert(season)
                }

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
        viewModel.set(data: [.init(data: data)], for: imageType)
    }

}
