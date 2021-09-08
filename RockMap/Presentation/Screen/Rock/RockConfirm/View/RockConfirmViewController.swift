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

        viewModel.output.$rockUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: rockUploadStateSink)
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.name(viewModel.rockEntity.name)], toSection: .name)
        snapShot.appendItems([.desc(viewModel.rockEntity.desc)], toSection: .desc)
        snapShot.appendItems([.season(viewModel.rockEntity.seasons)], toSection: .season)
        snapShot.appendItems([.lithology(viewModel.rockEntity.lithology)], toSection: .lithology)
        let location = LocationManager.LocationStructure(
            location: .init(
                latitude: viewModel.rockEntity.location.latitude,
                longitude: viewModel.rockEntity.location.longitude
            ),
            address: viewModel.rockEntity.address,
            prefecture: viewModel.rockEntity.prefecture
        )
        snapShot.appendItems([.location(location)], toSection: .location)
        snapShot.appendItems([.header(viewModel.header)], toSection: .header)
        snapShot.appendItems(
            viewModel.images.filter { !$0.shouldDelete } .map { ItemKind.images($0) },
            toSection: .images
        )
        snapShot.appendItems([.register], toSection: .register)
        datasource.apply(snapShot)
    }
}

extension RockConfirmViewController {

    private func rockUploadStateSink(_ state: LoadingState<Void>) {
        switch state {
            case .stanby: break

            case .loading:
                showIndicatorView()

            case .finish:
                viewModel.input.uploadImageSubject.send()

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "岩の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }

    private func imageUploadStateSink(_ state: LoadingState<Void>) {
        switch state {
            case .stanby: break

            case .loading:
                showIndicatorView()

            case .finish:
                hideIndicatorView()
                router.route(to: .dismiss, from: self)

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                ) { [weak self] _ in

                    guard let self = self else { return }

                    self.router.route(to: .dismiss, from: self)
                }
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
