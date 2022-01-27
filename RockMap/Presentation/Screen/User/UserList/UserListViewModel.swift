import Combine
import Foundation
import Resolver
import Domain
import Collections

actor UserListViewModel: ObservableObject {

    @Published nonisolated var users: OrderedSet<Entity.User> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    private var page: Int = 0

    @Injected private var fetchUserListUsecase: FetchUserListUsecaseProtocol

    @MainActor func load() async {
        self.viewState = .loading

        do {
            let users = try await fetchUserListUsecase.fetch(startAt: startAt)
            self.users.append(contentsOf: users)
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

    func shouldAdditionalLoad(user: Entity.User) async -> Bool {
        guard let index = users.firstIndex(of: user) else {
            return false
        }
        return user.id == users.last?.id
        && (Double(index) / 20.0) == 0.0
        && index != 0
    }

    private var startAt: Date {
        if let last = users.last {
            return last.createdAt
        } else {
            return Date()
        }
    }
}
