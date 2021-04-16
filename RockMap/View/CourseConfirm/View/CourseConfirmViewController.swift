//
//  CourseConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/25.
//

import Combine
import UIKit

class CourseConfirmViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var viewModel: CourseConfirmViewModel!
    var router: CourseConfirmRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseConfirmViewModel
    ) -> CourseConfirmViewController {
        let instance = CourseConfirmViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
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
                    self.viewModel.registerCourse()
                    
                case .failure(let error):
                    self.hideIndicatorView()
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
                    self.showIndicatorView()

                case .finish:
                    self.hideIndicatorView()
                    self.router.route(to: .rockDetail, from: self)
                    
                case .failure(let error):
                    self.showOKAlert(
                        title: "岩の登録に失敗しました",
                        message: error?.localizedDescription ?? ""
                    )
                    
                }
            }
            .store(in: &bindings)
    }
    
    private func setupCollectionView() {
        configureCollectionView()
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.rock(viewModel.rockHeaderStructure)], toSection: .rock)
        snapShot.appendItems([.courseName(viewModel.courseName)], toSection: .courseName)
        snapShot.appendItems([.desc(viewModel.desc)], toSection: .desc)
        snapShot.appendItems([.grade(viewModel.grade)], toSection: .grade)
        snapShot.appendItems([.shape(viewModel.shape)], toSection: .shape)
        snapShot.appendItems([.header(viewModel.header)], toSection: .header)
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
