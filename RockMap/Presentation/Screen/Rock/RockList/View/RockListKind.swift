import Foundation

extension RockListViewController {
    enum SectionKind: CaseIterable, Hashable {
        case annotationHeader
        case main
    }

    enum ItemKind: Hashable {
        case annotationHeader
        case rock(Entity.Rock)
    }
}
