import Combine
import Collections

class SearchFilterViewModel: ObservableObject {
    @Published var seasons: [Entity.Rock.Season] = []
    @Published var lithology: Entity.Rock.Lithology?
    @Published var prefecture: Resources.Prefecture?

    @Published var grade: Entity.Course.Grade?

    @MainActor func reset() {
        lithology = nil
        prefecture = nil

        grade = nil
    }

    func update(searchCondition: SearchCondition) {
        self.lithology = searchCondition.lithology
        self.prefecture = searchCondition.prefecture
        self.grade = searchCondition.grade
    }

    func makeSearchCondition(text: String) -> SearchCondition {
        .init(
            searchText: text,
            seasons: seasons,
            lithology: lithology,
            prefecture: prefecture,
            grade: grade
        )
    }
}
