//
//  CourseConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/25.
//

import Combine
import UIKit

class CourseConfirmViewController: UIViewController, CollectionViewControllerProtocol {

    var collectionView: TouchableColletionView!
    var viewModel: CourseConfirmViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    let indicator = UIActivityIndicatorView()
    
    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseConfirmViewModel
    ) -> CourseConfirmViewController {
        let instance = CourseConfirmViewController()
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
                    self.viewModel.registerCourse()
                    
                case .failure(let error):
                    self.indicator.stopAnimating()
                    self.showOKAlert(
                        title: "画像の登録に失敗しました",
                        message: error.localizedDescription
                    )
                    
                }
            }
            .store(in: &bindings)
        
        viewModel.$courseUploadState
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.dismiss(animated: true) { [weak self] in
                                
                                guard let self = self else { return }
                                
                                guard
                                    let rockDetailViewController = self.getVisibleViewController() as? RockDetailViewController
                                else {
                                    return
                                }
                                
                                rockDetailViewController.updateCouses()
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
        setupCollectionView(layout: createLayout())
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
        snapShot.appendItems([.rock(viewModel.rock)], toSection: .rock)
        snapShot.appendItems([.courseName(viewModel.courseName)], toSection: .courseName)
        snapShot.appendItems([.desc(viewModel.desc)], toSection: .desc)
        snapShot.appendItems([.grade(viewModel.grade)], toSection: .grade)
        snapShot.appendItems(viewModel.images.map { ItemKind.images($0) }, toSection: .images)
        snapShot.appendItems([.register], toSection: .register)
        datasource.apply(snapShot)
    }
}

extension CourseConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}
