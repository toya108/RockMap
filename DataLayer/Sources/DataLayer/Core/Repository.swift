
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

public extension Repository where T: FirestoreRequestProtocol {
    func request(
        useTestData: Bool = false,
        parameters: T.Parameters,
        completion: @escaping (Result<T.Response, Error>) -> Void
    ) {

        let item = T(parameters: parameters)
        FirestoreManager.db.document(item.path).getDocument { snapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let snapshot = snapshot,
                let dictionaly = snapshot.data(),
                let document = initializeDocument(json: dictionaly)
            else {
                completion(.failure(FirestoreError.nilResultError))
                return
            }

            completion(.success(document))
        }

    }

    func initializeDocument(json: [String: Any]) -> T.Response? {
        do {
            return try FirestoreManager.decoder.decode(T.Response.self, from: json)
        } catch {
            print("type:\(Self.self) のdecodeに失敗しました。reason: \(error.localizedDescription)")
            assertionFailure()
            return nil
        }
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
