enum LoadingState<T>: Equatable {
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        return false
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

    var error: Error? {
        if case let .failure(error) = self {
            return error
        } else {
            return nil
        }
    }
}
