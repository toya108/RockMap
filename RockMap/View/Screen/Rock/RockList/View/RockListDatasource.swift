//
//  RockListDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import UIKit

extension RockListViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case .annotationHeader:
                    let registration = UICollectionView.CellRegistration<
                        AnnotationHeaderCollectionViewCell,
                        Dummy
                    > { cell, _, _ in
                        cell.configure(title: "長押しすると編集/削除ができます。")
                    }

                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: Dummy()
                    )

                case let .rock(rock):
                    let registration = UICollectionView.CellRegistration<
                        ListCollectionViewCell,
                        FIDocument.Rock
                    >(
                        cellNib: .init(
                            nibName: ListCollectionViewCell.className,
                            bundle: nil
                        )
                    ) { cell, _, _ in
                        cell.configure(
                            imageUrl: rock.headerUrl,
                            title: "🪨 " + rock.name,
                            first: "登録日: " + rock.createdAt.string(dateStyle: .medium),
                            second: "住所: " + rock.address,
                            third: rock.desc
                        )
                    }

                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: rock
                    )
            }

        }
        return datasource
    }

}
