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
        let userIDShare = output.$fetchUserState
            .filter { $0.isFinished }
            .compactMap { $0.content?.id }
            .share()

        userIDShare
            .flatMap {
                FirestoreManager.db
                    .collectionGroup(FIDocument.Climbed.colletionName)
                    .whereField("registeredUserId", in: [$0])
                    .getDocuments(FIDocument.Climbed.self)
                    .catch { _ in Empty() }
            }
            .map { Set<FIDocument.Climbed>($0) }
            .assign(to: &output.$climbedList)

        userIDShare
            .map {
                StorageManager.makeReference(parent: FINameSpace.Users.self, child: $0)
            }
            .flatMap {
                StorageManager.getHeaderReference($0).catch { _ in Empty() }
            }
            .assign(to: &output.$headerImageReference)

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
