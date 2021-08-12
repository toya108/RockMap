
import Foundation

struct FireStoreClient<R: FirestoreRequestProtocol> {}

extension FireStoreClient where R.Entry == FSQuery  {

    func request(
        item: R,
        useTestData: Bool = false,
        completion: @escaping (Result<R.Response, Error>) -> Void
    ) {
        switch item.method {
            case .get:
                item.entry.getDocuments { snap, error in

                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let snap = snap else {
                        completion(.failure(FirestoreError.nilResultError))
                        return
                    }

                    let jsons = snap.documents.compactMap { $0.data() }
                    let documents = jsons.compactMap {
                        R.Document.initialize(json: $0)
                    }

                    guard let response = documents as? R.Response else {
                        completion(.failure(FirestoreError.nilResultError))
                        return
                    }

                    completion(.success(response))
                }
            case .set, .delete, .update:
                assertionFailure("query don't support other than read")
        }
    }

}

extension FireStoreClient where R.Entry == FSDocument, R.Response: Decodable {
    func request(
        item: R,
        useTestData: Bool = false,
        completion: @escaping (Result<R.Response, Error>) -> Void
    ) {
        switch item.method {
            case .get:
                item.entry.getDocument { snap, error in

                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard
                        let snap = snap,
                        let document = R.Document.initialize(json: snap.data() ?? [:]),
                        let response = document as? R.Response
                    else {
                        completion(.failure(FirestoreError.nilResultError))
                        return
                    }

                    completion(.success(response))
                }
            case .set, .delete, .update:
                break
        }
    }
}

extension FireStoreClient where R.Entry == FSDocument, R.Response == EmptyResponse {
    func request(
        item: R,
        useTestData: Bool = false,
        completion: @escaping (Result<R.Response, Error>) -> Void
    ) {
        switch item.method {
            case .get:
                break
            case .set:
                do {
                    try item.entry.setData(item.parameters.makedictionary()) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        completion(.success(R.Response()))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .delete:
                break
            case .update:
                break
        }
    }
}

private extension Encodable {

    func makedictionary(shouldExcludeEmpty: Bool = false) throws -> [String: Any] {
        let dictionaly = try FirestoreManager.encoder.encode(self)

        if shouldExcludeEmpty {
            return dictionaly.makeEmptyExcludedDictionary()
        } else {
            return dictionaly
        }
    }
}
