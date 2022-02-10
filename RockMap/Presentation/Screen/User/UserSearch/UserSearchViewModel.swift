import Combine
import Foundation
import Resolver
import Domain
import Collections

actor UserSearchViewModel: ObservableObject {

    @Published nonisolated var users: OrderedSet<Entity.User> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    @Injected private var searchUserUsecase: SearchUserUsecaseProtocol

    @MainActor func search(condition: SearchCondition) async {
        self.viewState = .loading

        do {
            let users = try await searchUserUsecase.search(text: condition.searchText)
            self.users.removeAll()
            self.users.append(contentsOf: users)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }
}
