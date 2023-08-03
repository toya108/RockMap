import Combine
import Foundation
import Resolver
import Collections

@MainActor
class UserSearchViewModel: ObservableObject {

    @Published var users: OrderedSet<Entity.User> = []
    @Published var viewState: LoadableViewState = .standby

    @Injected private var searchUserUsecase: SearchUserUsecaseProtocol

    func search(condition: SearchCondition) async {
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
