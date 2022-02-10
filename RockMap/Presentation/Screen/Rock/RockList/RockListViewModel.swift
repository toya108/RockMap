import Combine
import Foundation
import Resolver
import Domain
import Collections

actor RockListViewModel: ObservableObject {

    @Published nonisolated var rocks: OrderedSet<Entity.Rock> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    @Injected private var fetchRockListUsecase: FetchRockListUsecaseProtocol

    @MainActor func load(
        condition: SearchCondition,
        isAdditional: Bool = false
    ) async {
        self.viewState = .loading

        do {
            let rocks = try await fetchRockListUsecase.fetch(
                startAt: isAdditional ? startAt : Date(), area: condition.area
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
        await self.load(condition: condition, isAdditional: true)
    }

    func shouldAdditionalLoad(rock: Entity.Rock) async -> Bool {
        guard let index = rocks.firstIndex(of: rock) else {
            return false
        }
        return rock.id == rocks.last?.id
        && Float(index).truncatingRemainder(dividingBy: 20.0) == 0.0
        && index != 0
    }

    private var startAt: Date {
        if let last = rocks.last {
            return last.createdAt
        } else {
            return Date()
        }
    }
}
