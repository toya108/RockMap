
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

    init(userKind: UserKind) {

        self.userKind = userKind

        self.input = .init()
        self.output = .init()

        setupInput()
        setupOutput()
    }

    private func setupInput() {
        input.finishedCollectionViewSetup
            .sink { [weak self] in
                self?.fetchUser()
            }
            .store(in: &bindings)
    }

    private func setupOutput() {
        output.$fetchUserState
            .filter { $0.isFinished }
            .compactMap { $0.content?.id }
            .flatMap {
                FirestoreManager.db
                    .collectionGroup(FIDocument.ClimbRecord.colletionName)
                    .whereField("registeredUserId", in: [$0])
                    .getDocuments(FIDocument.ClimbRecord.self)
                    .catch { _ in Empty() }
            }
            .map { Set<FIDocument.ClimbRecord>($0) }
            .assign(to: &output.$climbedList)

        output.$climbedList
            .map { $0.map(\.parentCourseReference) }
            .map { Set<DocumentRef>($0) }
            .map { $0.prefix(5).map { $0 } }
            .flatMap {
                $0.getDocuments(FIDocument.Course.self).catch { _ in Empty() }
            }
            .map { Set<FIDocument.Course>($0) }
            .assign(to: &output.$recentClimbedCourses)
    }

    func fetchUser() {
        switch userKind {
            case .mine:
                fetchUser(from: AuthManager.shared.uid)

            case .guest:
                break

            case .other(let user):
                output.fetchUserState = .finish(content: user)
        }
    }

    private func fetchUser(from id: String) {
        output.fetchUserState = .loading

        fetchUserUsecase.fetchUser(by: id)
            .sinkState { [weak self] state in
                self?.output.fetchUserState = state
            }
            .store(in: &bindings)
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
                    
                case .other(let user):
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

                case .other(let user):
                    return user.id
            }
        }
    }
}

extension MyPageViewModel {

    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<(Void), Never>()
    }

    final class Output {
        @Published var isGuest = false
        @Published var fetchUserState: LoadingState<Entity.User> = .stanby
        @Published var climbedList: Set<FIDocument.ClimbRecord> = []
        @Published var recentClimbedCourses: Set<FIDocument.Course> = []
    }

}
