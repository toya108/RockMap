import Combine
import Collections

actor SearchFilterViewModel: ObservableObject {
    @Published nonisolated var seasons: [Entity.Rock.Season] = []
    @Published nonisolated var lithology: Entity.Rock.Lithology?
    @Published nonisolated var prefecture: Resources.Prefecture?
}
