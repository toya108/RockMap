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
        
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    func cell<T: UICollectionViewCell>(
        for type: T.Type,
        item: ItemKind
    ) -> T? {
        guard
            let indexPath = datasource.indexPath(for: item),
            case let cell as T = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }
        
        return cell
    }

}
