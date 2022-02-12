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
        lhs.area == rhs.area &&
        lhs.grade == rhs.grade
    }

    var searchText: String = ""

    var area: String = ""

    var grade: Entity.Course.Grade?
}