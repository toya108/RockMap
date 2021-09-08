
import Combine
import Foundation

public protocol RepositoryProtocol {
    associatedtype Request: RequestProtocol

    init()

    func request(
        useTestData: Bool,
        parameters: Request.Parameters
    ) -> AnyPublisher<Request.Response, Error>
}

public struct Repository<Request: RequestProtocol>: RepositoryProtocol {
    public init() {}

    public func request(
        useTestData: Bool = false,
        parameters: Request.Parameters
    ) -> AnyPublisher<Request.Response, Error> {
        let item = Request(parameters: parameters)
        return item.reguest(useTestData: useTestData, parameters: parameters)
    }
}
