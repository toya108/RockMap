import UIKit

extension RockListViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let headerCellRegistration = UICollectionView.CellRegistration<
            AnnotationHeaderCollectionViewCell,
            Dummy
        > { cell, _, _ in
            cell.configure(title: "長押しすると編集/削除ができます。")
        }

        let rockCellRegistration = UICollectionView.CellRegistration<
            ListCollectionViewCell,
            Entity.Rock
        >(
            cellNib: .init(
                nibName: ListCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, rock in
            cell.configure(
                imageUrl: rock.headerUrl,
                iconImage: UIImage.AssetsImages.rockFill,
                title: rock.name,
                first: "登録日: " + rock.createdAt.string(dateStyle: .medium),
                second: "住所: " + rock.address,
                third: rock.desc
            )
        }

        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            switch item {
            case .annotationHeader:
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .rock(rock):
                return collectionView.dequeueConfiguredReusableCell(
                    using: rockCellRegistration,
                    for: indexPath,
                    item: rock
                )
            }
        }
        
        return datasource
    }
}
