//
//  CompositionalColectionViewControllerProtocol.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/16.
//

import UIKit

protocol CompositionalColectionViewControllerProtocol: UIViewController, UICollectionViewDelegate {

    associatedtype SectionKind: Hashable
    associatedtype ItemKind: Hashable

    var collectionView: UICollectionView! { get set }
    var snapShot: NSDiffableDataSourceSnapshot<SectionKind, ItemKind> { get set }
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>! { get set }

    func configureCollectionView()
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind>
    func createLayout() -> UICollectionViewCompositionalLayout
}

extension CompositionalColectionViewControllerProtocol {

    func configureCollectionView() {
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
        collectionView.delegate = self

        datasource = configureDatasource()
    }

}
