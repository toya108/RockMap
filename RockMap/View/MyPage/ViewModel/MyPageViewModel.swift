//
//  MyPageViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import Combine

class MyPageViewModel: ViewModelProtocol {

    @Published var user: FIDocument.User?
    @Published var headerImageReference: StorageManager.Reference?

    @Published var fetchUserState: LoadingState = .stanby

    private var bindings = Set<AnyCancellable>()

    init(user: FIDocument.User?) {

        guard
            let user = user
        else {
            fetchUser()
            return
        }
        
        self.user = user

        setupBindings()
    }

    private func setupBindings() {
        $user
            .compactMap { $0?.name }
            .map {
                StorageManager.makeReference(parent: FINameSpace.Users.self, child: $0)
            }
            .flatMap { StorageManager.getHeaderReference($0) }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &$headerImageReference)
    }

    private func fetchUser() {

        fetchUserState = .loading

        AuthManager.shared.authUserReference
            .getDocument(FIDocument.User.self)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.fetchUserState = .finish

                        case .failure(let error):
                            self.fetchUserState = .failure(error)

                    }
                },
                receiveValue: { [weak self] user in

                    guard
                        let self = self,
                        let user = user
                    else {
                        return
                    }

                    self.user = user
                }
            )
            .store(in: &bindings)
    }

}

