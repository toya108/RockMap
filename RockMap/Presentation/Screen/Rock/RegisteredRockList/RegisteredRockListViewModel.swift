import Combine
import Resolver
import Foundation

class RegisteredRockListViewModel: ObservableObject {

    @Published var rocks: [Entity.Rock] = []
    @Published var isPresentedRockRegister = false
    @Published var isPresentedDeleteRockAlert = false
    @Published var isPresentedDeleteFailureAlert = false
    @Published var viewState: LoadableViewState = .standby
    var editingRock: Entity.Rock?
    var deleteError: Error?

    @Injected private var fetchRocksUsecase: FetchRockUsecaseProtocol
    @Injected private var deleteRockUsecase: DeleteRockUsecaseProtocol
    @Injected private var authAccessor: AuthAccessorProtocol

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    var isEditable: Bool {
        userId == authAccessor.uid
    }

    @MainActor func delete() {

        guard let rock = editingRock else {
            return
        }

        self.viewState = .loading

        Task {
            do {
                try await self.deleteRockUsecase.delete(id: rock.id)

                guard
                    let index = self.rocks.firstIndex(of: rock)
                else {
                    return
                }
                self.rocks.remove(at: index)
                self.viewState = .finish
            } catch {
                self.deleteError = error
                self.viewState = .finish
                self.isPresentedDeleteFailureAlert = true
            }
        }
    }

    @MainActor func fetchRockList() {
        self.viewState = .loading

        Task {
            let rocks = try await self.fetchRocksUsecase.fetch(by: self.userId)
            self.rocks = rocks.sorted { $0.createdAt > $1.createdAt }
            self.viewState = .finish
        }
    }
}
