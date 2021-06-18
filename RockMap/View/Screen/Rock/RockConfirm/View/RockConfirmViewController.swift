//
//  RockConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/12.
//

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

        configureCollectionView()
        setupNavigationBar()
        bindViewModelToView()
        configureSections()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "登録内容を確認"
    }
    
    private func bindViewModelToView() {
        viewModel.output.$imageUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUploadStateSink)
            .store(in: &bindings)

        viewModel.output.$imageUrlDownloadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUrlStateSink)
            .store(in: &bindings)

        viewModel.output.$rockUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockUploadStateSink)
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.name(viewModel.rockDocument.name)], toSection: .name)
        snapShot.appendItems([.desc(viewModel.rockDocument.desc)], toSection: .desc)
        snapShot.appendItems([.season(viewModel.rockDocument.seasons)], toSection: .season)
        snapShot.appendItems([.lithology(viewModel.rockDocument.lithology)], toSection: .lithology)
        let location = LocationManager.LocationStructure(
            location: .init(
                latitude: viewModel.rockDocument.location.latitude,
                longitude: viewModel.rockDocument.location.longitude
            ),
            address: viewModel.rockDocument.address,
            prefecture: viewModel.rockDocument.prefecture
        )
        snapShot.appendItems([.location(location)], toSection: .location)
        snapShot.appendItems([.header(viewModel.header)], toSection: .header)
        snapShot.appendItems(
            viewModel.images.filter(\.shouldAppendItem).map { ItemKind.images($0) },
            toSection: .images
        )
        snapShot.appendItems([.register], toSection: .register)
        datasource.apply(snapShot)
    }
}

extension RockConfirmViewController {

    private func imageUploadStateSink(_ state: StorageUploader.UploadState) {
        switch state {
            case .stanby:
                hideIndicatorView()

            case .progress:
                showIndicatorView()

            case .complete:
                hideIndicatorView()
                viewModel.input.downloadImageUrlSubject.send()

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error.localizedDescription
                )
        }
    }

    private func imageUrlStateSink(_ state: LoadingState<[ImageURL]>) {
        switch state {
            case .stanby:
                hideIndicatorView()

            case .loading:
                showIndicatorView()

            case .finish:
                hideIndicatorView()
                viewModel.input.registerRockSubject.send()

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }

    private func rockUploadStateSink(_ state: LoadingState<Void>) {
        switch state {
            case .stanby:
                break

            case .loading:
                showIndicatorView()

            case .finish:
                hideIndicatorView()
                router.route(to: .dismiss, from: self)

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "岩の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }

}

extension RockConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}
