import Combine
import Collections

class SearchFilterViewModel: ObservableObject {
    @Published var area: String = ""
    @Published var grade: Entity.Course.Grade?

    @MainActor func reset() {
        area = ""
        grade = nil
    }

    func makeSearchCondition(text: String) -> SearchCondition {
        .init(
            searchText: text,
            area: area,
            grade: grade
        )
    }
}
