import Foundation

extension MyClimbedListViewController {
    enum SectionKind: CaseIterable, Hashable {
        case main
    }

    enum ItemKind: Hashable {
        case course(MyClimbedListViewModel.ClimbedCourse)
    }
}
