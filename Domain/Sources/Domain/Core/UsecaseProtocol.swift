import Combine
import DataLayer
import Foundation

public protocol UsecaseProtocol {}

protocol PassthroughUsecaseProtocol {
    associatedtype Repository: RepositoryProtocol
    associatedtype Mapper: MapperProtocol

    var repository: Repository { get }
    var mapper: Mapper { get }

    init(repository: Repository, mapper: Mapper)
}
