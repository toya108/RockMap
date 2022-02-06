import Combine
import Collections

class SearchFilterViewModel: ObservableObject {
    @Published var seasons: [Entity.Rock.Season] = []
    @Published var lithology: Entity.Rock.Lithology?
    @Published var prefecture: Resources.Prefecture?

    @Published var grade: Entity.Course.Grade?
    @Published var shapes: [Entity.Course.Shape] = []

    @MainActor func reset() {
        seasons = []
        lithology = nil
        prefecture = nil

        grade = nil
        shapes = []
    }

    func update(searchCondition: SearchCondition) {
        self.lithology = searchCondition.lithology
        self.seasons = searchCondition.seasons
        self.prefecture = searchCondition.prefecture
        self.grade = searchCondition.grade
        self.shapes = searchCondition.shapes
    }

    func makeSearchCondition(text: String) -> SearchCondition {
        .init(
            searchText: text,
            seasons: seasons,
            lithology: lithology,
            prefecture: prefecture,
            grade: grade,
            shapes: shapes
        )
    }
}
