//
//  CourceRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit
import Combine
import PhotosUI

class CourceRegisterViewController: UIViewController, ColletionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var viewModel: CourceRegisterViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    private var bindings = Set<AnyCancellable>()
    
    let phPickerViewController: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        return PHPickerViewController(configuration: configuration)
    }()
    
    static func createInstance(
        viewModel: CourceRegisterViewModel
    ) -> CourceRegisterViewController {
        let instance = CourceRegisterViewController()
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView()
        setupNavigationBar()
        bindViewToViewModel()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
        phPickerViewController.delegate = self
    }
    
    private func setupColletionView() {
        setupColletionView(layout: createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "課題を登録する"

        navigationItem.setLeftBarButton(
            .init(
                systemItem: .cancel,
                primaryAction: .init {  [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true)
                }
            ),
            animated: false
        )
    }
    
    private func bindViewToViewModel() {
    }
    
    private func bindViewModelToView() {
        viewModel.$rockHeaderStructure
            .drop { $0.rockName.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.rock(rock)], toSection: .rock)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$images
            .drop { $0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
                
                self.snapShot.appendItems([.noImage], toSection: .images)
                
                let items = images.map { ItemKind.images($0) }
                self.snapShot.appendItems(items, toSection: .images)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initalItems, toSection: $0)
        }
        datasource.apply(snapShot)
    }
    
    @objc func reloadDescCell() {
        snapShot.reloadItems([.desc])
    }
}

extension CourceRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension CourceRegisterViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        collectionView.layoutIfNeeded()
        snapShot.reloadSections([.desc])
    }
}

extension CourceRegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 1)
        else {
            return
        }
        
//        indicator.startAnimating()
        viewModel.images.append(.init(data: data))
        dismiss(animated: true)
    }
}

extension CourceRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
//        indicator.startAnimating()

        picker.dismiss(animated: true)
        
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
                
                self.viewModel.images.append(.init(data: data))
            }
        }
    }
}
