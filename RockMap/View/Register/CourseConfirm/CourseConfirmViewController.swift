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
        
    }
    
    private func setupColletionView() {
        setupColletionView(layout: createLayout())
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
    }
    
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.rock(viewModel.rock)], toSection: .rock)
        snapShot.appendItems([.courseName(viewModel.courseName)], toSection: .courseName)
        snapShot.appendItems([.desc(viewModel.desc)], toSection: .desc)
        snapShot.appendItems([.grade(viewModel.grade)], toSection: .grade)
        snapShot.appendItems(viewModel.images.map { ItemKind.images($0) }, toSection: .images)
//        snapShot.appendItems([.confirmation], toSection: .confirmation)
        datasource.apply(snapShot)
    }
}
