//
//  MyPageViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import Combine

protocol MyPageViewModelProtocol {
    var input: MyPageViewModel.Input { get }
    var output: MyPageViewModel.Output { get }
}

class MyPageViewModel: MyPageViewModelProtocol, ViewModelProtocol {
    var input: Input
    var output: Output

    private var bindings = Set<AnyCancellable>()

    init(userReference: DocumentRef?) {

        self.input = .init()

        do {
            self.output = .init()
        }

        setupBindings()
        fetchUser(reference: userReference)
    }

    private func setupBindings() {

    }

    private func fetchUser(reference: DocumentRef?) {

        guard
            let reference = reference
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
                            self.output.fetchUserState = .finish

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

                    self.output.user = user
                }
            )
            .store(in: &bindings)
    }

}

extension MyPageViewModel {

    struct Input {}

    final class Output {
        @Published var user: FIDocument.User?
        @Published var isGuest = false
        @Published var headerImageReference: StorageManager.Reference = .init()
        @Published var fetchUserState: LoadingState = .stanby
    }

}
