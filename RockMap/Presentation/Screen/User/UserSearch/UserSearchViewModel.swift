import Combine
import Foundation
import Resolver
import Domain
import Collections

actor UserSearchViewModel: ObservableObject {

    @Published nonisolated var users: OrderedSet<Entity.User> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    private var page: Int = 0

    @Injected private var searchUserUsecase: SearchUserUsecaseProtocol

    @MainActor func search(
        condition: SearchCondition,
        isAdditional: Bool
    ) async {
        self.viewState = .loading

        do {
            let users = try await searchUserUsecase.search(text: condition.searchText)

            if !isAdditional {
                self.users.removeAll()
            }

            self.users.append(contentsOf: users)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad(condition: SearchCondition) async {
        self.page += 1
        await self.search(condition: condition, isAdditional: true)
    }

    func refresh(condition: SearchCondition) async {
        self.page = 0
        await self.search(condition: condition, isAdditional: false)
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
