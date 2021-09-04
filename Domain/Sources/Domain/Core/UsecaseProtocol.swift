import Combine
import Foundation
import DataLayer

public protocol UsecaseProtocol {
    init()
}

protocol PassthroughUsecaseProtocol {
    associatedtype Repository: RepositoryProtocol
    associatedtype Mapper: MapperProtocol

    var repository: Repository { get }
    var mapper: Mapper { get }

    init(repository: Repository, mapper: Mapper)
}
