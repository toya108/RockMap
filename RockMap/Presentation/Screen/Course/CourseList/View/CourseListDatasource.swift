import UIKit

extension CourseListViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {

        let headerCellRegistration = UICollectionView.CellRegistration<
            AnnotationHeaderCollectionViewCell,
            Dummy
        > { cell, _, _ in
            cell.configure(title: "課題を長押しすると編集/削除ができます。")
        }

        let courseCellRegistration = UICollectionView.CellRegistration<
            ListCollectionViewCell,
            Entity.Course
        >(
            cellNib: .init(
                nibName: ListCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, course in
            cell.configure(
                imageUrl: course.headerUrl,
                iconImage: UIImage.SystemImages.docPlaintextFill,
                title: course.name + " " + course.grade.name,
                first: "登録日: " + course.createdAt.string(dateStyle: .medium),
                second: "岩名: " + course.parentRockName,
                third: course.desc
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

            case let .course(course):
                return collectionView.dequeueConfiguredReusableCell(
                    using: courseCellRegistration,
                    for: indexPath,
                    item: course
                )
            }
        }
        return datasource
    }
}
