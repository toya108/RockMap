import Combine

extension Publisher {
    func sinkState<T>(
        _ setState: @escaping (LoadingState<T>) -> Void
    ) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                guard
                    case let .failure(error) = result
                else {
                    return
                }
                setState(.failure(error))
            },
            receiveValue: { content in
                guard
                    let content = content as? T
                else {
                    return
                }
                setState(.finish(content: content))
            }
        )
    }
}
