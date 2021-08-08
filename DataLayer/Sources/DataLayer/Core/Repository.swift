
import Foundation

public protocol RepositoryProtocol {
    associatedtype Request: RequestProtocol

    func request(
        useTestData: Bool,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    )

    func request(parameters: Request.Parameters) -> Request.Response?
}

public struct Repository<Request: RequestProtocol>: RepositoryProtocol {
    public init() {}

    public func request(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
        let item = Request(parameters: parameters)

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
    public func request(parameters: Request.Parameters) -> Request.Response? {
        let item = Request(parameters: parameters)
        return item.localDataInterceptor(parameters)
    }
}

public extension Repository where Request: FirestoreRequestProtocol {
    func request(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {

        let item = Request(parameters: parameters)
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

    func initializeDocument(json: [String: Any]) -> Request.Response? {
        do {
            return try FirestoreManager.decoder.decode(Request.Response.self, from: json)
        } catch {
            print("type:\(Self.self) のdecodeに失敗しました。reason: \(error.localizedDescription)")
            assertionFailure()
            return nil
        }
    }
}

public extension Repository where Request.Parameters == EmptyParameters {
    func request(
        useTestData: Bool = false,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
        self.request(
            useTestData: useTestData,
            parameters: .init(),
            completion: completion
        )
    }

    @discardableResult
    func request() -> Request.Response? {
        let item = Request(parameters: .init())
        return item.localDataInterceptor(.init())
    }
}
