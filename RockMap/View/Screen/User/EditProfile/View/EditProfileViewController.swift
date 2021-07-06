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

        let saveButton = UIBarButtonItem(
            title: "保存",
            image: nil,
            primaryAction: .init { [weak self] _ in

                guard let self = self else { return }

                self.startUpdateSequence()
            },
            menu: nil
        )
        saveButton.tintColor = UIColor.Pallete.primaryGreen
        navigationItem.setRightBarButton(
            saveButton,
            animated: true
        )
    }

    private func bindViewModelToView() {
        viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerSink)
            .store(in: &bindings)

        viewModel.output.$icon
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: iconSink)
            .store(in: &bindings)

        viewModel.output.$nameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: nameValidationSink)
            .store(in: &bindings)

        viewModel.output.$imageUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUploadStateSink)
            .store(in: &bindings)

        viewModel.output.$userUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: uploadLoadingStateSink)
            .store(in: &bindings)
    }

    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        datasource.apply(snapShot)
    }

    private func startUpdateSequence() {
        guard
            viewModel.callValidations()
        else {
            showOKAlert(
                title: "入力内容に不備があります。",
                message: "入力内容を見直してください。"
            )
            return
        }
        viewModel.editProfile()
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
        viewModel.input.setImageSubject.send((imageType, data))
    }
}

extension EditProfileViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

}

extension EditProfileViewController {

    private func headerSink(_ image: CrudableImage<FIDocument.User>) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .header))

        let shouldAppend = image.updateData != nil
            || image.storageReference != nil
            && !image.shouldDelete

        snapShot.appendItems([shouldAppend ? .header(image) : .noImage], toSection: .header)
        datasource.apply(snapShot)

        hideIndicatorView()
    }

    private func iconSink(_ image: CrudableImage<FIDocument.User>) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .icon))
        snapShot.appendItems([.icon(image)], toSection: .icon)
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


    private func imageUploadStateSink(_ state: StorageUploader.UploadState) {
        switch state {
            case .stanby:
                hideIndicatorView()

            case .progress:
                showIndicatorView()

            case .complete:
                hideIndicatorView()
                dismiss(animated: true) { [weak self] in
                    guard
                        let self = self,
                        case let myPageVc as MyPageViewController = self.getVisibleViewController()
                    else {
                        return
                    }
                    myPageVc.viewModel.fetchUser()
                }

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error.localizedDescription
                ) { [weak self] _ in

                    guard let self = self else { return }

                    self.dismiss(animated: true)
                }
        }
    }

    private func uploadLoadingStateSink(_ state: LoadingState<Void>) {
        switch state {
            case .stanby:
                break

            case .loading:
                showIndicatorView()

            case .finish:
                hideIndicatorView()
                viewModel.uploadImage()

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "編集に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }

}
