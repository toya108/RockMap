import Combine
import Resolver
import Auth
import Domain
import Foundation

class RockListViewModelV2: ObservableObject {

    @Published var rocks: [Entity.Rock] = []
    @Published var isEmpty = false
    @Published var deleteState: LoadingState<Void> = .stanby
    @Published var shouldShowRockRegister = false
    var editingRockIndex: Int = -1

    @Injected private var fetchRocksUsecase: FetchRockUsecaseProtocol
    @Injected private var delteRockUsecase: DeleteRockUsecaseProtocol
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

    @MainActor func delete(rock: Entity.Rock) {

        self.deleteState = .loading

        Task {
            do {
                try await self.delteRockUsecase.delete(
                    id: rock.id,
                    parentPath: rock.parentPath
                )

                guard
                    let index = self.rocks.firstIndex(of: rock)
                else {
                    return
                }
                self.rocks.remove(at: index)
                self.deleteState = .finish(content: ())
            } catch {
                self.deleteState = .failure(error)
            }
        }
    }

    @MainActor func fetchRockList() {
        Task {
            let rocks = try await self.fetchRocksUsecase.fetch(by: self.userId)
            self.rocks = rocks.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
