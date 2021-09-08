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
        navigationItem.title = "課題を\(viewModel.registerType.name)する"

        navigationItem.setRightBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init {  [weak self] _ in
                    
                    guard let self = self else { return }

                    self.router.route(to: .rockDetail, from: self)
                }
            ),
            animated: false
        )
    }
    
    private func bindViewModelToView() {
        viewModel.output.$grade
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: gradeSink)
            .store(in: &bindings)

        viewModel.output.$shapes
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: shapeSink)
            .store(in: &bindings)

        viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerSink)
            .store(in: &bindings)
        
        viewModel.output.$images
            .drop { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imagesSink)
            .store(in: &bindings)
        
        viewModel.output.$courseNameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseNameValidationSink)
            .store(in: &bindings)
        
        viewModel.output.$courseImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseImageValidationSink)
            .store(in: &bindings)

        viewModel.output.$headerImageValidationResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerImageValidationSink)
            .store(in: &bindings)
    }
    
    private func configureSections() {
        if case .create = viewModel.registerType {
            snapShot.appendSections([.rock])
            snapShot.appendItems([.rock], toSection: .rock)
        }

        snapShot.appendSections(SectionLayoutKind.allCases.filter { $0 != .rock })

        SectionLayoutKind.allCases.filter { $0 != .rock }.forEach {
            snapShot.appendItems($0.initalItems, toSection: $0)
        }
        let shapeItems = Entity.Course.Shape.allCases.map {
            ItemKind.shape(shape: $0, isSelecting: viewModel.output.shapes.contains($0))
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
        imageType: Entity.Image.ImageType
    ) {
        viewModel.input.setImageSubject.send((data, imageType))
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
                viewModel.input.shapeSubject.send([shape])
            
            default:
                break
        }
    }
    
}

extension CourseRegisterViewController {

    private func gradeSink(_ grade: Entity.Course.Grade) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .grade))
        snapShot.appendItems([.grade(grade)], toSection: .grade)
        datasource.apply(snapShot)
    }

    private func shapeSink(_ shapes: Set<Entity.Course.Shape>) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .shape))
        let items = Entity.Course.Shape.allCases.map {
            ItemKind.shape(shape: $0, isSelecting: shapes.contains($0))
        }
        snapShot.appendItems(items, toSection: .shape)
        datasource.apply(snapShot)
    }

    private func headerSink(_ crudableImage: CrudableImage) {

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

    private func imagesSink(_ crudableImages: [CrudableImage]) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .images))
        snapShot.appendItems([.noImage(.normal)], toSection: .images)

        let items = crudableImages.filter { !$0.shouldDelete } .map { ItemKind.images($0) }
        snapShot.appendItems(items, toSection: .images)
        datasource.apply(snapShot)

        hideIndicatorView()
    }

    private func courseNameValidationSink(_ result: ValidationResult) {
        switch result {
            case .valid, .none:
                let items = snapShot.itemIdentifiers(inSection: .courseName)

                guard
                    let item = items.first(where: { $0.isErrorItem })
                else {
                    return
                }

                snapShot.deleteItems([item])

            case let .invalid(error):
                let items = snapShot.itemIdentifiers(inSection: .courseName)

                if let item = items.first(where: { $0.isErrorItem }) {
                    snapShot.deleteItems([item])
                }

                snapShot.appendItems([.error(error)], toSection: .courseName)
        }
        datasource.apply(snapShot)
    }

    private func courseImageValidationSink(_ result: ValidationResult) {
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

                self.snapShot.deleteItems([item])

            case let .invalid(error):
                if let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) }) {
                    self.snapShot.deleteItems([item])
                }
                self.snapShot.appendItems([.error(error)], toSection: .confirmation)

        }

        datasource.apply(snapShot)
    }

}
