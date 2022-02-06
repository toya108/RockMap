import Combine
import Domain
import Foundation
import Resolver

actor SearchRootViewModel: ObservableObject {
    @Published nonisolated var searchCondition: SearchCondition = .init()
    @Published nonisolated var selectedCategory: CategoryKind = .rock
    @Published nonisolated var disabledFilterButton = false
    @Published nonisolated var isPresentedSearchFilter = false

    private var cancellables = Set<AnyCancellable>()

    func setupBindings() {
        $selectedCategory
            .receive(on: DispatchQueue.main)
            .map { $0 == .user }
            .assign(to: &$disabledFilterButton)
    }

    @MainActor func resetSearchText() {
        searchCondition.searchText = ""
    }
}

struct SearchCondition: Equatable {
    static func == (lhs: SearchCondition, rhs: SearchCondition) -> Bool {
        lhs.searchText == rhs.searchText &&
        lhs.seasons == rhs.seasons &&
        lhs.lithology == rhs.lithology &&
        lhs.prefecture == rhs.prefecture &&
        lhs.grade == rhs.grade &&
        lhs.shapes == rhs.shapes
    }

    var searchText: String = ""

    var seasons: [Entity.Rock.Season] = []
    var lithology: Entity.Rock.Lithology?
    var prefecture: Resources.Prefecture?

    var grade: Entity.Course.Grade?
    var shapes: [Entity.Course.Shape] = []
}
