
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
    private var deleteRock: Entity.Rock?
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
            .handleEvents(receiveOutput: { [weak self] rock in

                guard let self = self else { return }

                self.output.deleteState = .loading
                self.deleteRock = rock
            })
            .flatMap {
                self.delteRockUsecase.delete(id: $0.id, parentPath: $0.parentPath)
                    .catch { [weak self] error -> Empty in

                        guard let self = self else { return Empty() }

                        self.output.deleteState = .failure(error)
                        return Empty()
                    }
            }
            .sink { [weak self] _ in
                guard
                    let self = self,
                    let deleteRock = self.deleteRock,
                    let index = self.output.rocks.firstIndex(of: deleteRock)
                else {
                    return
                }
                self.output.rocks.remove(at: index)
                self.output.deleteState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$rocks
            .map(\.isEmpty)
            .assign(to: &self.output.$isEmpty)
    }

    func fetchRockList() {
        self.fetchRocksUsecase.fetch(by: self.userId)
            .catch { error -> Just<[Entity.Rock]> in
                print(error)
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &self.output.$rocks)
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
