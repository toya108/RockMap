//
//  CourseDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit
import Combine

class CourseDetailViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    private var viewModel: CourseDetailViewModel!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(viewModel: CourseDetailViewModel) -> CourseDetailViewController {
        let instance = CourseDetailViewController()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
//        setupNavigationBar()
        datasource = configureDatasource()
        bindViewToViewModel()
//        configureSections()
    }
    
    private func setupCollectionView() {
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
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
//    private func setupNavigationBar() {
//        guard
//            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
//        else {
//            return
//        }
//
//        rockMapNavigationBar.setup()
//
//        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }
    
    private func bindViewToViewModel() {
        
    }

}
