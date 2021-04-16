//
//  CourseRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit
import Combine
import PhotosUI

class CourseRegisterViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var viewModel: CourseRegisterViewModel!
    var router: CourseRegisterRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

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

        setupColletionView()
        setupPickerManager()
        setupNavigationBar()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
    }
    
    private func setupColletionView() {
        configureCollectionView()
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
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
        navigationItem.title = "課題を登録する"

        navigationItem.setLeftBarButton(
            .init(
                systemItem: .cancel,
                primaryAction: .init {  [weak self] _ in
                    
                    guard let self = self else { return }

                    self.router.route(to: .rockDetail, from: self)
                }
            ),
            animated: false
        )
    }
    
    private func bindViewModelToView() {
        viewModel.$rockHeaderStructure
            .drop { $0.rock.name.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.rock(rock)], toSection: .rock)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$header
            .receive(on: RunLoop.main)
            .sink { [weak self] data in

                defer {
                    self?.hideIndicatorView()
                }

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .header))

                if let data = data {
                    self.snapShot.appendItems([.header(data)], toSection: .header)

                } else {
                    self.snapShot.appendItems([.noImage(.header)], toSection: .header)

                }

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$images
            .drop { $0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                
                defer {
                    self?.hideIndicatorView()
                }
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
                
                self.snapShot.appendItems([.noImage(.normal)], toSection: .images)
                self.snapShot.appendItems(images.map { ItemKind.images($0) }, toSection: .images)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$courseNameValidationResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                
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
            }
            .store(in: &bindings)
        
        viewModel.$grade
            .receive(on: RunLoop.main)
            .sink { [weak self] grade in
            
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .grade))
                
                self.snapShot.appendItems([.grade(grade)], toSection: .grade)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$courseImageValidationResult
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
        
        viewModel.$shape
            .receive(on: RunLoop.main)
            .sink { [weak self] shape in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .shape))
                
                let items = FIDocument.Course.Shape.allCases.map { ItemKind.shape(shape: $0, isSelecting: shape.contains($0)) }
                self.snapShot.appendItems(items, toSection: .shape)
 
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initalItems, toSection: $0)
        }
        let shapeItems = FIDocument.Course.Shape.allCases.map {
            ItemKind.shape(shape: $0, isSelecting: viewModel.shape.contains($0))
        }
        snapShot.appendItems(shapeItems, toSection: .shape)
        datasource.apply(snapShot)
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
        imageType: ImageType
    ) {
        viewModel.set(
            data: [.init(data: data)],
            for: imageType
        )
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
            
            if viewModel.shape.contains(shape) {
                viewModel.shape.remove(shape)
            } else {
                viewModel.shape.insert(shape)
            }
            
        default:
            break
        }
    }
    
}
