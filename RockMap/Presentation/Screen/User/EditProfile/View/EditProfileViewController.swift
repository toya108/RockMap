import Combine
import PhotosUI
import UIKit

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
        self.setupPickerManager()
        self.setupNavigationBar()
        self.bindViewModelToView()
        self.configureSections()
    }

    private func setupPickerManager() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        self.pickerManager = PickerManager(
            from: self,
            configuration: configuration
        )
        self.pickerManager.delegate = self
    }

    private func setupNavigationBar() {
        navigationItem.title = "プロフィール編集"

        navigationItem.setLeftBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                primaryAction: .init { [weak self] _ in

                    guard let self = self else { return }

                    self.showAlert(
                        title: "編集内容を破棄しますか？",
                        actions: [
                            .init(title: "破棄", style: .destructive) { _ in
                                self.dismiss(animated: true)
                            },
                            .init(title: "キャンセル", style: .cancel),
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
        self.viewModel.output.$header
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerSink)
            .store(in: &self.bindings)

        self.viewModel.output.$icon
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: iconSink)
            .store(in: &self.bindings)

        self.viewModel.output.$nameValidationResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: nameValidationSink)
            .store(in: &self.bindings)

        self.viewModel.output.$imageUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUploadStateSink)
            .store(in: &self.bindings)

        self.viewModel.output.$userUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: uploadLoadingStateSink)
            .store(in: &self.bindings)
    }

    private func configureSections() {
        self.snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        self.datasource.apply(self.snapShot)
    }

    private func startUpdateSequence() {
        guard
            self.viewModel.callValidations()
        else {
            showOKAlert(
                title: "入力内容に不備があります。",
                message: "入力内容を見直してください。"
            )
            return
        }
        self.viewModel.editProfile()
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
        imageType: Entity.Image.ImageType
    ) {
        self.viewModel.input.setImageSubject.send((imageType, data))
    }
}

extension EditProfileViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension EditProfileViewController {
    private func headerSink(_ crudableImage: CrudableImage) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .header))

        let shouldAppend = crudableImage.updateData != nil
            || crudableImage.image.url != nil
            && !crudableImage.shouldDelete

        self.snapShot.appendItems(
            [shouldAppend ? .header(crudableImage) : .noImage],
            toSection: .header
        )
        self.datasource.apply(self.snapShot)

        hideIndicatorView()
    }

    private func iconSink(_ crudableImage: CrudableImage) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .icon))
        self.snapShot.appendItems([.icon(crudableImage)], toSection: .icon)
        self.datasource.apply(self.snapShot)

        hideIndicatorView()
    }

    private func nameValidationSink(_ result: ValidationResult) {
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

    private func imageUploadStateSink(_ state: LoadingState<Void>) {
        switch state {
        case .stanby:
            hideIndicatorView()

        case .loading:
            showIndicatorView()

        case .finish:
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

        case let .failure(error):
            hideIndicatorView()
            showOKAlert(
                title: "画像の登録に失敗しました",
                message: error?.localizedDescription ?? ""
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
            self.viewModel.uploadImage()

        case let .failure(error):
            hideIndicatorView()
            showOKAlert(
                title: "編集に失敗しました",
                message: error?.localizedDescription ?? ""
            )
        }
    }
}
