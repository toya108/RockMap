import Combine
import DataLayer
import Foundation

protocol PassthroughUsecaseProtocol {
    associatedtype Repository: RepositoryProtocol
    associatedtype Mapper: MapperProtocol

    var repository: Repository { get }
    var mapper: Mapper { get }

    init(repository: Repository, mapper: Mapper)
}

protocol ListenableUsecaseProtocol {
    associatedtype Repository: ListenableRepositoryProtocol
    associatedtype Mapper: MapperProtocol

    var repository: Repository { get }
    var mapper: Mapper { get }

    init(repository: Repository, mapper: Mapper)
}
