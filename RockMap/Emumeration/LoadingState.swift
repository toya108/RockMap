//
//  LoadingState.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

enum LoadingState<T>: Equatable {

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
    case finish(content: T)
    case failure(Error?)

    var content: T? {
        guard
            case let .finish(content) = self
        else {
            return nil
        }
        return content
    }
}
