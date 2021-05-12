//
//  MyPageViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

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
        let userStateShare = output.$fetchUserState.share()

        userStateShare
            .compactMap { $0.content }
            .flatMap {
                FirestoreManager.db
                    .collectionGroup(FIDocument.Climbed.colletionName)
                    .whereField("registeredUserId", in: [$0.id])
                    .getDocuments(FIDocument.Climbed.self)
            }
            .catch { _ -> Just<[FIDocument.Climbed]> in
                return .init([])
            }
            .map { Set<FIDocument.Climbed>($0) }
            .assign(to: &output.$climbedList)

        userStateShare
            .drop(while: { !$0.isFinished })
            .breakpoint()
            .compactMap { $0.content?.id }
            .flatMap { id -> AnyPublisher<StorageManager.Reference?, Error> in
                let userStorageReference = StorageManager.makeReference(
                    parent: FINameSpace.Users.self,
                    child: id
                )
                return StorageManager.getHeaderReference(userStorageReference)
            }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &output.$headerImageReference)

        output.$climbedList
            .map { $0.map(\.parentCourseReference) }
            .map { Set<DocumentRef>($0) }
            .map { $0.prefix(5).map { $0 } }
            .flatMap { $0.getDocuments(FIDocument.Course.self) }
            .catch { _ -> Just<[FIDocument.Course]> in
                return .init([])
            }
            .map {Set<FIDocument.Course>($0) }
            .assign(to: &output.$recentClimbedCourses)
    }

    func fetchUser() {
        switch userKind {
            case .mine:
                if let reference = AuthManager.shared.authUserReference {
                    fetchUser(reference: reference)
                }
            case .guest:
                break

            case .other(let user):
                output.fetchUserState = .finish(content: user)
        }
    }

    private func fetchUser(reference: DocumentRef) {
        output.fetchUserState = .loading

        reference
            .getDocument(FIDocument.User.self)
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
        case other(user: FIDocument.User)

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
    }
}

extension MyPageViewModel {

    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<(Void), Never>()
    }

    final class Output {
        @Published var isGuest = false
        @Published var headerImageReference: StorageManager.Reference?
        @Published var fetchUserState: LoadingState<FIDocument.User> = .stanby
        @Published var climbedList: Set<FIDocument.Climbed> = []
        @Published var recentClimbedCourses: Set<FIDocument.Course> = []
    }

}
