import Combine
import Domain
import Resolver

actor SearchRootViewModel: ObservableObject {
    @Published nonisolated var searchCondition: SearchCondition = .init()
    @Published nonisolated var selectedCategory: CategoryKind = .rock
    @Published nonisolated var isPresentedSearchFilter = false

    private var cancellables = Set<AnyCancellable>()

    @MainActor func resetSearchText() {
        searchCondition.searchText = ""
    }
}

class SearchCondition: ObservableObject, Equatable {
    static func == (lhs: SearchCondition, rhs: SearchCondition) -> Bool {
        lhs.searchText == rhs.searchText
    }

    @Published var searchText: String = ""
}
