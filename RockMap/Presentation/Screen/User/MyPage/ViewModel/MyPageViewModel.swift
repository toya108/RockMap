
import Auth
import Combine

protocol MyPageViewModelProtocol: ViewModelProtocol {
    var input: MyPageViewModel.Input { get }
    var output: MyPageViewModel.Output { get }
}

class MyPageViewModel: MyPageViewModelProtocol {
    var input: Input
    var output: Output
    let userKind: UserKind

    private var bindings = Set<AnyCancellable>()
    private let fetchUserUsecase = Usecase.User.FetchById()
    private let fetchClimbRecordsUsecase = Usecase.ClimbRecord.FetchByUserId()
    private let fetchCourseUsecase = Usecase.Course.FetchByReference()

    init(userKind: UserKind) {
        self.userKind = userKind

        self.input = .init()
        self.output = .init()

        self.setupInput()
        self.setupOutput()
    }

    private func setupInput() {
        self.input.finishedCollectionViewSetup
            .sink { [weak self] in
                self?.fetchUser()
            }
            .store(in: &self.bindings)
    }

    private func setupOutput() {
        self.output.$fetchUserState
            .filter(\.isFinished)
            .compactMap { $0.content?.id }
            .flatMap {
                self.fetchClimbRecordsUsecase.fetch(by: $0).catch { error -> Empty in
                    print(error)
                    return Empty()
                }
            }
            .assign(to: &self.output.$climbedList)

        self.output.$climbedList
            .map { $0.map(\.parentCourseReference).unique.prefix(5) }
            .flatMap {
                $0.publisher.flatMap { id in
                    self.fetchCourseUsecase.fetch(by: id).catch { error -> Empty in
                        print(error)
                        return Empty()
                    }
                }
                .collect()
            }
            .assign(to: &self.output.$recentClimbedCourses)
    }

    func fetchUser() {
        switch self.userKind {
        case .mine:
            self.fetchUser(from: AuthManager.shared.uid)

        case .guest:
            break

        case let .other(user):
            self.output.fetchUserState = .finish(content: user)
        }
    }

    private func fetchUser(from id: String) {
        self.output.fetchUserState = .loading

        self.fetchUserUsecase.fetchUser(by: id)
            .sinkState { [weak self] state in
                self?.output.fetchUserState = state
            }
            .store(in: &self.bindings)
    }
}

extension MyPageViewModel {
    enum UserKind {
        case guest
        case mine
        case other(user: Entity.User)

        var title: String {
            switch self {
            case .guest, .mine:
                return "マイページ"

            case let .other(user):
                return user.name
            }
        }

        var isMine: Bool {
            if case .mine = self {
                return true
            } else {
                return false
            }
        }

        var userId: String {
            switch self {
            case .guest:
                return ""

            case .mine:
                return AuthManager.shared.uid

            case let .other(user):
                return user.id
            }
        }
    }
}

extension MyPageViewModel {
    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var isGuest = false
        @Published var fetchUserState: LoadingState<Entity.User> = .stanby
        @Published var climbedList: [Entity.ClimbRecord] = []
        @Published var recentClimbedCourses: [Entity.Course] = []
    }
}
