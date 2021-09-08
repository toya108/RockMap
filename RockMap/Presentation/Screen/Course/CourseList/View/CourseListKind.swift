import Foundation

extension CourseListViewController {
    enum SectionKind: CaseIterable, Hashable {
        case annotationHeader
        case main
    }

    enum ItemKind: Hashable {
        case annotationHeader
        case course(Entity.Course)
    }
}
