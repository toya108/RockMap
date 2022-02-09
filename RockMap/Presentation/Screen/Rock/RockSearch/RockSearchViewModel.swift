import Combine
import Foundation
import Resolver
import Domain
import Collections

actor RockSearchViewModel: ObservableObject {

    @Published nonisolated var rocks: OrderedSet<Entity.Rock> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    @Injected private var searchRockListUsecase: SearchRockUsecaseProtocol

    @MainActor func search(
        condition: SearchCondition,
        isAdditional: Bool
    ) async {
        self.viewState = .loading

        do {
            let rocks = try await searchRockListUsecase.search(
                text: condition.searchText,
                area: condition.area
            )

            if !isAdditional {
                self.rocks.removeAll()
            }

            self.rocks.append(contentsOf: rocks)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad(condition: SearchCondition) async {
        await self.search(condition: condition, isAdditional: true)
    }

    func shouldAdditionalLoad(rock: Entity.Rock) async -> Bool {
        guard let index = rocks.firstIndex(of: rock) else {
            return false
        }
        return rock.id == rocks.last?.id
        && (Double(index) / 20.0) == 0.0
        && index != 0
    }
}
