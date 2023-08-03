import Combine
import Foundation
import Resolver
import Collections

@MainActor
class UserListViewModel: ObservableObject {

    @Published var users: OrderedSet<Entity.User> = []
    @Published var viewState: LoadableViewState = .standby

    @Injected private var fetchUserListUsecase: FetchUserListUsecaseProtocol

    func load(isAdditional: Bool = false) async {
        self.viewState = .loading

        do {
            let users = try await fetchUserListUsecase.fetch(
                startAt: isAdditional ? startAt : Date()
            )
            if !isAdditional {
                self.users.removeAll()
            }
            self.users.append(contentsOf: users)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad() async {
        await self.load(isAdditional: true)
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
