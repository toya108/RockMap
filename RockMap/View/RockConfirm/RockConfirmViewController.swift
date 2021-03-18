//
//  RockConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/12.
//

import Combine
import UIKit

class RockConfirmViewController: UIViewController {

    var collectionView: UICollectionView!
    var viewModel: RockConfirmViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    let indicator = UIActivityIndicatorView()
    
    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: RockConfirmViewModel
    ) -> RockConfirmViewController {
        let instance = RockConfirmViewController()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView()
        setupNavigationBar()
        setupIndicator()
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
                    self.indicator.stopAnimating()
                    
                case .progress(let unitCount):
                    self.indicator.startAnimating()
                    
                case .complete(let metaDatas):
                    self.indicator.stopAnimating()
                    self.viewModel.registerRock()
                    
                case .failure(let error):
                    self.indicator.stopAnimating()
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
                    self.indicator.startAnimating()
                    
                case .finish:
                    self.indicator.stopAnimating()
                    RegisterSucceededViewController.showSuccessView(present: self) {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            
                            guard let self = self else { return }
                            
                            self.dismiss(animated: true) { [weak self] in
                                
                                guard let self = self else { return }
                                
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.showOKAlert(
                        title: "岩の登録に失敗しました",
                        message: error.localizedDescription
                    )
                    
                }
            }
            .store(in: &bindings)
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
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.name(viewModel.rockName)], toSection: .name)
        snapShot.appendItems([.desc(viewModel.rockDesc)], toSection: .desc)
        snapShot.appendItems([.season(viewModel.seasons)], toSection: .season)
        snapShot.appendItems([.lithology(viewModel.lithology)], toSection: .lithology)
        snapShot.appendItems([.location(viewModel.rockLocation)], toSection: .location)
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
