import Combine
import Foundation
import Resolver
import Domain
import Collections

actor RockListViewModel: ObservableObject {

    @Published nonisolated var rocks: OrderedSet<Entity.Rock> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    private var page: Int = 0

    @Injected private var fetchRockListUsecase: FetchRockListUsecaseProtocol

    @MainActor func load() async {
        self.viewState = .loading

        do {
            let rocks = try await fetchRockListUsecase.fetch(startAt: startAt)
            self.rocks.append(contentsOf: rocks)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad() async {
        self.page += 1
        await self.load()
    }

    func refresh() async {
        self.page = 0
        await self.load()
    }

    func shouldAdditionalLoad(rock: Entity.Rock) async -> Bool {
        guard let index = rocks.firstIndex(of: rock) else {
            return false
        }
        return rock.id == rocks.last?.id
        && (Double(index) / 20.0) == 0.0
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
