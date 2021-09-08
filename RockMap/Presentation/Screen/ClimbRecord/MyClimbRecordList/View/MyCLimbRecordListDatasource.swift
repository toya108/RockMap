import UIKit

extension MyClimbedListViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] _, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
            case let .course(course):
                let registration = UICollectionView.CellRegistration<
                    ListCollectionViewCell,
                    MyClimbedListViewModel.ClimbedCourse
                >(
                    cellNib: .init(
                        nibName: ListCollectionViewCell.className,
                        bundle: nil
                    )
                ) { cell, _, climbedCourse in
                    cell.configure(
                        imageUrl: climbedCourse.course.headerUrl,
                        title: climbedCourse.course.name,
                        first: "グレード: " + climbedCourse.course.grade.name,
                        second: "完登日: " + climbedCourse.climbed.climbedDate
                            .string(dateStyle: .medium),
                        third: "完登方法: " + climbedCourse.climbed.type.name
                    )
                }

                return self.collectionView.dequeueConfiguredReusableCell(
                    using: registration,
                    for: indexPath,
                    item: course
                )
            }
        }
        return datasource
    }
}
