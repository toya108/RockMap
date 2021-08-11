
import Foundation

struct FireStoreClient<R: FirestoreRequestProtocol> {}

extension FireStoreClient where R.Entry == FSQuery {

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
                        R.Collection.Document.initializeDocument(json: $0)
                    }

                    guard let response = documents as? R.Response else {
                        completion(.failure(FirestoreError.nilResultError))
                        return
                    }

                    completion(.success(response))
                }
            case .set:
                break
            case .delete:
                break
            case .update:
                break
        }
    }

}

extension FireStoreClient where R.Entry == FSDocument {
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
                        let document = R.Collection.Document.initializeDocument(json: snap.data() ?? [:]),
                        let response = document as? R.Response
                    else {
                        completion(.failure(FirestoreError.nilResultError))
                        return
                    }

                    completion(.success(response))
                }
            case .set:
                break
            case .delete:
                break
            case .update:
                break
        }
    }
}
