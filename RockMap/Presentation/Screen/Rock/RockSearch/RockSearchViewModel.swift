import Combine
import Foundation
import Resolver
import Domain
import Collections

class RockSearchViewModel: ObservableObject {

    @Published var rocks: OrderedSet<Entity.Rock> = []
    @Published var viewState: LoadableViewState = .standby

    @Injected private var searchRockListUsecase: SearchRockUsecaseProtocol

    func search(condition: SearchCondition) async {
        self.viewState = .loading

        do {
            let rocks = try await searchRockListUsecase.search(
                text: condition.searchText,
                area: condition.area
            )

            self.rocks.removeAll()
            self.rocks.append(contentsOf: rocks)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }
}
