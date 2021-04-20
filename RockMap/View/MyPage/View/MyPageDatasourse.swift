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
                case let .headerImage(reference):
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: self.configureHeaderImageCell(),
                        for: indexPath,
                        item: reference
                    )
            }
        }

        return datasource
    }


    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        .init { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
        }
    }
}
