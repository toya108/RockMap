import Combine
import Domain
import Foundation
import Resolver

class SearchRootViewModel: ObservableObject {
    @Published var searchCondition: SearchCondition = .init()
    @Published var selectedCategory: CategoryKind = .rock
    @Published var disabledFilterButton = false
    @Published var isPresentedSearchFilter = false

    private var cancellables = Set<AnyCancellable>()

    func setupBindings() {
        $selectedCategory
            .receive(on: DispatchQueue.main)
            .map { $0 == .user }
            .assign(to: &$disabledFilterButton)
    }

    func resetSearchText() {
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
