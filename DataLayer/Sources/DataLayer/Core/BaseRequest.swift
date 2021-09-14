import Combine
import Foundation

public struct EmptyParameters: Encodable, Equatable {
    public init() {}
}

public struct EmptyResponse: Codable, Equatable {
    public init() {}
}

public protocol RequestProtocol {
    associatedtype Response: Decodable
    associatedtype Parameters

    var parameters: Parameters { get }
    func localDataInterceptor(parameters: Parameters) -> AnyPublisher<Response, Error>

    #if DEBUG
    var testDataPath: URL? { get }
    #endif

    init(parameters: Parameters)

    func reguest(useTestData: Bool, parameters: Parameters) -> AnyPublisher<Response, Error>
}

public extension RequestProtocol {
    func localDataInterceptor(parameters: Parameters) -> AnyPublisher<Response, Error> {
        Empty<Response, Error>().eraseToAnyPublisher()
    }
}
