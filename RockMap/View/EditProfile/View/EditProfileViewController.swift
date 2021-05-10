//
//  EditProfileViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//

import UIKit
import Combine
import PhotosUI

class EditProfileViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var viewModel: EditProfileViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    var bindings = Set<AnyCancellable>()

    var pickerManager: PickerManager!

    static func createInstance(
        viewModel: EditProfileViewModel
    ) -> EditProfileViewController {
        let instance = EditProfileViewController()
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
        configuration.selectionLimit = 1
        configuration.filter = .images
        pickerManager = PickerManager(
            from: self,
            configuration: configuration
        )
        pickerManager.delegate = self
    }

    private func setupNavigationBar() {
        navigationItem.title = "プロフィール編集"

        navigationItem.setLeftBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init {  [weak self] _ in

                    guard let self = self else { return }

                    self.showAlert(
                        title: "編集内容を破棄しますか？",
                        actions: [
                            .init(title: "破棄", style: .destructive) { _ in
                                self.dismiss(animated: true)
                            },
                            .init(title: "キャンセル", style: .cancel)
                        ],
                        style: .actionSheet
                    )
                }
            ),
            animated: false
        )

        navigationItem.setRightBarButton(
            .init(
                title: "保存",
                image: nil,
                primaryAction: .init { _ in

                },
                menu: nil
            ),
            animated: true
        )
    }

    private func bindViewModelToView() {

        viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerSink)
            .store(in: &bindings)

        viewModel.output.$nameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: nameValidationSink)
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
        datasource.apply(snapShot)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension EditProfileViewController: PickerManagerDelegate {

    func beganResultHandling() {
        showIndicatorView()
    }

    func didReceivePicking(
        data: Data,
        imageType: ImageType
    ) {
        viewModel.input.setImageSubject.send(.data(.init(data: data)))
    }
}

extension EditProfileViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

}

extension EditProfileViewController {

    private func headerSink(_ imageDataKind: ImageDataKind?) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .header))

        if
            let kind = imageDataKind,
            kind.shouldAppendItem
        {
            snapShot.appendItems([.header(kind)], toSection: .header)
        } else {
            snapShot.appendItems([.noImage], toSection: .header)
        }
        datasource.apply(snapShot)

        hideIndicatorView()
    }

    private func nameValidationSink(_ result: ValidationResult) {
        switch result {
            case .valid, .none:
                let items = snapShot.itemIdentifiers(inSection: .name)

                guard
                    let item = items.first(where: { $0.isErrorItem })
                else {
                    return
                }

                snapShot.deleteItems([item])

            case let .invalid(error):
                let items = snapShot.itemIdentifiers(inSection: .name)

                if let item = items.first(where: { $0.isErrorItem }) {
                    snapShot.deleteItems([item])
                }

                snapShot.appendItems([.error(error)], toSection: .name)
        }
        datasource.apply(snapShot)
    }

    private func headerImageValidationSink(_ result: ValidationResult) {
//        switch result {
//            case .valid, .none:
//                guard
//                    let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) })
//                else {
//                    return
//                }
//
//                self.snapShot.deleteItems([item])
//
//            case let .invalid(error):
//                if let item = items.first(where: { $0 == .error(.none(formName: "ヘッダー画像")) }) {
//                    self.snapShot.deleteItems([item])
//                }
//                self.snapShot.appendItems([.error(error)], toSection: .confirmation)
//
//        }
//
//        datasource.apply(snapShot)
    }

}
