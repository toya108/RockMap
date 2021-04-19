//
//  MyPageDatasourse.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import UIKit

extension MyPageViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {

        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case .name:
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRockCell(),
                        for: indexPath,
                        item: Dummy()
                    )
            }
        }

        return datasource
    }


    private func configureRockCell() -> UICollectionView.CellRegistration<
        RockHeaderCollectionViewCell,
        Dummy
    > {
        .init {_,_,_ in }
    }
}
