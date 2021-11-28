import Auth
import Combine

protocol RockListViewModelProtocol: ViewModelProtocol {
    var input: RockListViewModel.Input { get }
    var output: RockListViewModel.Output { get }

    func fetchRockList()
}

class RockListViewModel: RockListViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()

    let isMine: Bool
    private let userId: String
    private let fetchRocksUsecase = Usecase.Rock.FetchByUserId()
    private let delteRockUsecase = Usecase.Rock.Delete()

    private var bindings = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId
        self.isMine = userId == AuthManager.shared.uid

        self.bindInput()
        self.bindOutput()
        self.fetchRockList()
    }

    private func bindInput() {
        self.input.deleteRockSubject
            .handleEvents(receiveOutput: { [weak self] _ in

                guard let self = self else { return }

                self.output.deleteState = .loading
            })
            .asyncSink { [weak self] rock in

                guard let self = self else { return }

                do {
                    try await self.delteRockUsecase.delete(
                        id: rock.id,
                        parentPath: rock.parentPath
                    )

                    guard
                        let index = self.output.rocks.firstIndex(of: rock)
                    else {
                        return
                    }
                    self.output.rocks.remove(at: index)
                    self.output.deleteState = .finish(content: ())
                } catch {
                    self.output.deleteState = .failure(error)
                }
            }
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$rocks
            .map(\.isEmpty)
            .assign(to: &self.output.$isEmpty)
    }

    func fetchRockList() {
        Task {
            let rocks = try await self.fetchRocksUsecase.fetch(by: self.userId)
            self.output.rocks = rocks.sorted { $0.createdAt > $1.createdAt }
        }
    }
}

extension RockListViewModel {
    struct Input {
        let deleteRockSubject = PassthroughSubject<Entity.Rock, Never>()
    }

    final class Output {
        @Published var rocks: [Entity.Rock] = []
        @Published var isEmpty: Bool = false
        @Published var deleteState: LoadingState<Void> = .stanby
    }
}
