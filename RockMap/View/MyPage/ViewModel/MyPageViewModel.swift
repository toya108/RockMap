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

    private let userReference: DocumentRef?

    private var bindings = Set<AnyCancellable>()

    init(userReference: DocumentRef?) {

        self.userReference = userReference

        self.input = .init()
        self.output = .init()

        setupBindings()
        fetchUser()
    }

    private func setupBindings() {
        output.$fetchUserState
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

        output.$climbedList
            .map { $0.map(\.parentCourseReference) }
            .map { Set<DocumentRef>($0) }
            .map { $0.prefix(5).map { $0 } }
            .sink { prefixes in
                prefixes
                    .map { $0.getDocument(FIDocument.Course.self) }
                    .forEach {
                        $0.catch { _ -> Just<FIDocument.Course?> in
                            return .init(nil)
                        }
                        .compactMap { $0 }
                        .sink { [weak self] course in

                            guard let self = self else { return }

                            self.output.recentClimbedCourses.insert(course)
                        }
                        .store(in: &self.bindings)
                    }
            }
            .store(in: &bindings)
    }

    func fetchUser() {

        guard
            let reference = userReference
        else {
            output.isGuest = true
            return
        }

        output.fetchUserState = .loading

        reference
            .getDocument(FIDocument.User.self)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            break
                        case .failure(let error):
                            self.output.fetchUserState = .failure(error)

                    }
                },
                receiveValue: { [weak self] user in
                    guard
                        let self = self,
                        let user = user
                    else {
                        return
                    }
                    self.output.fetchUserState = .finish(content: user)
                }
            )
            .store(in: &bindings)
    }

}

extension MyPageViewModel {

    struct Input {}

    final class Output {
        @Published var isGuest = false
        @Published var headerImageReference: StorageManager.Reference = .init()
        @Published var fetchUserState: LoadingState<FIDocument.User> = .stanby
        @Published var climbedList: Set<FIDocument.Climbed> = []
        @Published var recentClimbedCourses: Set<FIDocument.Course> = []
    }

}
