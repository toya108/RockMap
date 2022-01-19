import Combine
import Resolver
import Auth
import Domain
import Foundation

class RockListViewModel: ObservableObject {

    @Published var rocks: [Entity.Rock] = []
    @Published var isEmpty = false
    @Published var isPresentedRockRegister = false
    @Published var isPresentedDeleteRockAlert = false
    @Published var isPresentedDeleteFailureAlert = false
    @Published var isLoading = false
    var editingRock: Entity.Rock?
    var deleteError: Error?

    @Injected private var fetchRocksUsecase: FetchRockUsecaseProtocol
    @Injected private var deleteRockUsecase: DeleteRockUsecaseProtocol
    @Injected private var authAccessor: AuthAccessorProtocol

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    private func bindOutput() {
        self.$rocks
            .map(\.isEmpty)
            .assign(to: &self.$isEmpty)
    }

    @MainActor func delete() {

        guard let rock = editingRock else {
            return
        }

        self.isLoading = true

        Task {
            do {
                try await self.deleteRockUsecase.delete(id: rock.id)

                guard
                    let index = self.rocks.firstIndex(of: rock)
                else {
                    return
                }
                self.rocks.remove(at: index)
                self.isLoading = false
            } catch {
                self.deleteError = error
            }
        }
    }

    @MainActor func fetchRockList() {
        self.isLoading = true

        Task {
            let rocks = try await self.fetchRocksUsecase.fetch(by: self.userId)
            self.rocks = rocks.sorted { $0.createdAt > $1.createdAt }
            self.isLoading = false
        }
    }
}
