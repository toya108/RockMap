//
//  LoadingState.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

enum LoadingState: Equatable {
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
            case (.stanby, .stanby), (.loading, .loading), (.finish, .finish), (.failure, failure):
                return true

            default:
                return false
        }
    }

    case stanby
    case loading
    case finish
    case failure(Error?)
}
