//
//  CourseConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/25.
//

import UIKit

class CourseConfirmViewController: UIViewController, ColletionViewControllerProtocol {

    var collectionView: TouchableColletionView!
    var viewModel: CourseConfirmViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    static func createInstance(
        viewModel: CourseConfirmViewModel
    ) -> CourseConfirmViewController {
        let instance = CourseConfirmViewController()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView(layout: createLayout())
        setupNavigationBar()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "登録内容を確認"
    }
    
    private func bindViewModelToView() {
        
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.rock(viewModel.rock)], toSection: .rock)
        snapShot.appendItems([.courceName(viewModel.courseName)], toSection: .courceName)
        snapShot.appendItems([.desc(viewModel.desc)], toSection: .desc)
        snapShot.appendItems(viewModel.images.map { ItemKind.images($0) }, toSection: .images)
        snapShot.appendItems([.grade(viewModel.grade)], toSection: .grade)
        snapShot.appendItems([.confirmation], toSection: .confirmation)
    }
}
