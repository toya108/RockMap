//
//  CourceRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit
import Combine

class CourceRegisterViewController: UIViewController, ColletionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var viewModel: CourceRegisterViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    private var bindings = Set<AnyCancellable>()
    
    static func createInstance(
        viewModel: CourceRegisterViewModel
    ) -> CourceRegisterViewController {
        let instance = CourceRegisterViewController()
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView()
        setupNavigationBar()
        bindViewToViewModel()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
    }
    
    private func setupColletionView() {
        setupColletionView(layout: createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "課題を登録する"

        navigationItem.setLeftBarButton(
            .init(
                systemItem: .cancel,
                primaryAction: .init {  [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true)
                }
            ),
            animated: false
        )
    }
    
    private func bindViewToViewModel() {
    }
    
    private func bindViewModelToView() {
        viewModel.$rockHeaderStructure
            .drop { $0.rockName.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.rock(rock)], toSection: .rock)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        snapShot.appendItems([.courceName], toSection: .courceName)
        FIDocument.Cource.Grade.allCases.forEach {
            snapShot.appendItems([.grade($0)], toSection: .grade)
        }
        datasource.apply(snapShot)
    }
}

extension CourceRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
