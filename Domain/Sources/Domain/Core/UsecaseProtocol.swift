import Combine
import Foundation
import DataLayer

protocol UsecaseProtocol {
    associatedtype Repository: RepositoryProtocol
    associatedtype Mapper: MapperProtocol

    var repository: Repository { get }
    var mapper: Mapper { get }

    init(repository: Repository, mapper: Mapper)
}

extension UsecaseProtocol {

    func toPublisher<T, E: Error>(
        closure: @escaping (@escaping Future<T, E>.Promise) -> Void
    ) -> AnyPublisher<T, E> {
        Deferred {
            Future { promise in
                closure(promise)
            }
        }.eraseToAnyPublisher()
    }
}
