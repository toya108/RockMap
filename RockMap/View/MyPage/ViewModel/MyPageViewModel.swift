//
//  MyPageViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import Combine

class MyPageViewModel: ViewModelProtocol {

    @Published var user: FIDocument.User
    @Published var userName: String
    @Published var headerImageReference: StorageManager.Reference?

    private var bindings = Set<AnyCancellable>()

    init(user: FIDocument.User) {
        self.user = user
        self.userName = user.name
        setupBindings()
    }

    private func setupBindings() {
        $userName
            .map {
                StorageManager.makeReference(parent: FINameSpace.Users.self, child: $0)
            }
            .flatMap { StorageManager.getHeaderReference($0) }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &$headerImageReference)
    }

}

