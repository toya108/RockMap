//
//  File.swift
//  
//
//  Created by TOUYA KAWANO on 2021/08/06.
//

import Foundation

public protocol RepositoryProtocol {
    associatedtype T: RequestProtocol

    func request(
        useTestData: Bool,
        parameters: T.Parameters,
        completion: @escaping (Result<T.Response, Error>) -> Void
    )

    func request(parameters: T.Parameters) -> T.Response?
}

public struct Repository<T: RequestProtocol>: RepositoryProtocol {
    public init() {}

    public func request(
        useTestData: Bool = false,
        parameters: T.Parameters,
        completion: @escaping (Result<T.Response, Error>) -> Void
    ) {
        let item = T(parameters: parameters)

//        APIClient().request(item: item, useTestData: useTestData) { result in
//
//            switch result {
//                case let .success(value):
//                    item.successHandler(value)
//                case let .failure(error):
//                    item.failureHandler(error)
//            }
//
//            completion(result)
//        }
    }

    @discardableResult
    public func request(parameters: T.Parameters) -> T.Response? {
        let item = T(parameters: parameters)
        return item.localDataInterceptor(parameters)
    }
}

public extension Repository where T.Parameters == EmptyParameters {
    func request(
        useTestData: Bool = false,
        completion: @escaping (Result<T.Response, Error>) -> Void
    ) {
        self.request(
            useTestData: useTestData,
            parameters: .init(),
            completion: completion
        )
    }

    @discardableResult
    func request() -> T.Response? {
        let item = T(parameters: .init())
        return item.localDataInterceptor(.init())
    }
}
