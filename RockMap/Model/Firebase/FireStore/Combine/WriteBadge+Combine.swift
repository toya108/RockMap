//
//  WriteBadge+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/10.
//

import Combine
import FirebaseFirestore

extension WriteBatch {

    func commit() -> AnyPublisher<Void, Error> {

        Deferred {
            Future<Void, Error> { [weak self] promise in

                guard let self = self else { return }

                self.commit { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()

    }

}
