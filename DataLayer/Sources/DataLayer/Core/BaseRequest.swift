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
}
