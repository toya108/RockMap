//
//  File.swift
//  
//
//  Created by TOUYA KAWANO on 2021/08/06.
//

import Foundation


public struct EmptyParameters: Encodable, Equatable {
    public init() {}
}

public struct EmptyResponse: Codable, Equatable {
    public init() {}
}


public protocol RequestProtocol {
    associatedtype Response: Decodable
    associatedtype Parameters: Encodable

    var parameters: Parameters { get }
    var localDataInterceptor: (Parameters) -> Response? { get }

    #if DEBUG
    var testDataPath: URL? { get }
    #endif

    init(
        parameters: Parameters
    )
}

public extension RequestProtocol {

    var localDataInterceptor: (Parameters) -> Response? { { _ in nil } }

}
