//
//  RockRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit
import Combine
import PhotosUI

class RockRegisterViewController: UIViewController {

    var collectionView: UICollectionView!
    var viewModel: RockRegisterViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    let indicator = UIActivityIndicatorView()
    
    private var bindings = Set<AnyCancellable>()
    
    let phPickerViewController: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        return PHPickerViewController(configuration: configuration)
    }()
    
    static func createInstance(
        viewModel: RockRegisterViewModel
    ) -> RockRegisterViewController {
        let instance = self.init()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColletionView()
        setupIndicator()
        setupNavigationBar()
        datasource = configureDatasource()
        bindViewModelToView()
        phPickerViewController.delegate = self
        configureSections()
    }
    
    private func setupColletionView() {
        collectionView = .init(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        collectionView.delegate = self
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
    }
    
    private func setupIndicator() {
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.Pallete.transparentBlack
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.rightAnchor.constraint(equalTo: view.rightAnchor),
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        indicator.bringSubviewToFront(collectionView)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "岩を登録する"
        navigationItem.setRightBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init { [weak self] _ in

                    guard let self = self else { return }

                    self.dismiss(animated: true)
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
                    self?.indicator.stopAnimating()
                }
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
                
                self.snapShot.appendItems([.noImage], toSection: .images)
                
                let items = images.map { ItemKind.images($0) }
                self.snapShot.appendItems(items, toSection: .images)
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

                    self.snapShot.appendItems([.error(error.description)], toSection: .name)
                }
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$rockImageValidationResult
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                
                guard let self = self else { return }
                
                if isValid {
                    let items = self.snapShot.itemIdentifiers(inSection: .confirmation)
                    
                    guard
                        let item = items.first(where: { $0.isErrorItem })
                    else {
                        return
                    }
                    self.snapShot.deleteItems([item])

                } else {
                    let items = self.snapShot.itemIdentifiers(inSection: .confirmation)
                    
                    if let item = items.first(where: { $0.isErrorItem }) {
                        self.snapShot.deleteItems([item])
                    }

                    self.snapShot.appendItems([.error("画像のアップロードは必須です。")], toSection: .confirmation)
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

extension RockRegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 1)
        else {
            return
        }
        
        indicator.startAnimating()
        viewModel.rockImageDatas.append(.init(data: data))
        picker.dismiss(animated: true)
    }
}

extension RockRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        if results.isEmpty { return }
        
        indicator.startAnimating()
        
        results.map(\.itemProvider).forEach {
            
            guard $0.canLoadObject(ofClass: UIImage.self) else { return }
            
            $0.loadObject(ofClass: UIImage.self) { [weak self] providerReading, error in
                guard
                    case .none = error,
                    let self = self,
                    let image = providerReading as? UIImage,
                    let data = image.jpegData(compressionQuality: 1)
                else {
                    return
                }
                
                self.viewModel.rockImageDatas.append(.init(data: data))
            }
        }
    }
}

extension RockRegisterViewController: UICollectionViewDelegate {
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
