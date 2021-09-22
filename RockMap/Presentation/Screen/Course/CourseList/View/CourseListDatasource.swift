import UIKit

extension CourseListViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] _, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
            case .annotationHeader:
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.registrations.headerCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .course(course):
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: self.registrations.courseCellRegistration,
                    for: indexPath,
                    item: course
                )
            }
        }
        return datasource
    }
}

extension CourseListViewController {
    struct Registrations {
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

    }

}
