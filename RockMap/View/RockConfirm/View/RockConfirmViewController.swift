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

        setupColletionView()
        setupNavigationBar()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "登録内容を確認"
    }
    
    private func bindViewModelToView() {
        viewModel.$imageUploadState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                
                guard let self = self else { return }
                
                switch $0 {
                case .stanby:
                    self.hideIndicatorView()
                    
                case .progress(let _):
                    self.showIndicatorView()

                case .complete(let _):
                    self.hideIndicatorView()
                    self.viewModel.registerRock()
                    
                case .failure(let error):
                    self.hideIndicatorView()
                    self.showOKAlert(
                        title: "画像の登録に失敗しました",
                        message: error.localizedDescription
                    )
                    
                }
            }
            .store(in: &bindings)
        
        viewModel.$rockUploadState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                
                guard let self = self else { return }
                
                switch $0 {
                case .stanby:
                    break
                    
                case .loading:
                    self.showIndicatorView()

                case .finish:
                    self.hideIndicatorView()
                    self.router.route(to: .rockSearch, from: self)
                    
                case .failure(let error):
                    self.showOKAlert(
                        title: "岩の登録に失敗しました",
                        message: error?.localizedDescription ?? ""
                    )
                    
                }
            }
            .store(in: &bindings)
    }
    
    private func setupColletionView() {
        configureCollectionView()
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.name(viewModel.rockName)], toSection: .name)
        snapShot.appendItems([.desc(viewModel.rockDesc)], toSection: .desc)
        snapShot.appendItems([.season(viewModel.seasons)], toSection: .season)
        snapShot.appendItems([.lithology(viewModel.lithology)], toSection: .lithology)
        snapShot.appendItems([.location(viewModel.rockLocation)], toSection: .location)
        snapShot.appendItems([.headerImage(viewModel.rockHeaderImage)], toSection: .headerImage)
        snapShot.appendItems(viewModel.rockImageDatas.map { ItemKind.images($0) }, toSection: .images)
        snapShot.appendItems([.register], toSection: .register)
        datasource.apply(snapShot)
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
