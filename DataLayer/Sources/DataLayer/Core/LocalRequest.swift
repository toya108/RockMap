
import Foundation

protocol LocalRequest: RequestProtocol {}

extension LocalRequest {
    public var parameters: Parameters { fatalError() }
    public var testDataPath: URL? { nil }
}
