import Combine
import Foundation

public extension Publisher {

    func asyncMap<T>(
        transform: @escaping (Output) async throws -> T,
        errorCompletion: @escaping (Error) -> Void
    ) -> Publishers.FlatMap<AnyPublisher<T, Never>, Self> {
        flatMap { value in
            Future<T, Error> { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .catch { error -> Empty in
                errorCompletion(error)
                return Empty()
            }
            .eraseToAnyPublisher()
        }
    }

}

public extension Publisher where Self.Failure == Never {
    func asyncSink(
        receiveValue: @escaping ((Self.Output) async -> Void)
    ) -> AnyCancellable {
        return sink { output in
            Task {
                await receiveValue(output)
            }
        }
    }

}

public enum MemoryError: LocalizedError {
    case noneSelf
}
