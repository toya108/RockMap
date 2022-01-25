enum LoadingState<T>: Equatable {
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.standby, .standby), (.loading, .loading), (.finish, .finish), (.failure, failure):
            return true

        default:
            return false
        }
    }

    case standby
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

    var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }

    var isFinished: Bool {
        if case .finish = self {
            return true
        } else {
            return false
        }
    }
}
