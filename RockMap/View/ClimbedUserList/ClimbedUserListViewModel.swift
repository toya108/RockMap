//
//  ClimbedUserListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import Combine
import FirebaseFirestore

class ClimbedUserListViewModel {

    struct ClimbedCellData: Hashable {
        let climbed: FIDocument.Climbed
        let user: FIDocument.User
        let isOwned: Bool
    }

    private let course: FIDocument.Course
    @Published private var climbedList: [FIDocument.Climbed] = []
    @Published var climbedCellData: [ClimbedCellData] = []
    private var bindings = Set<AnyCancellable>()

    init(course: FIDocument.Course) {
        self.course = course
        fetchClimbed(course: course)
        setupBindings()
    }

    private func fetchClimbed(course: FIDocument.Course) {
        course.makeDocumentReference()
            .collection(FIDocument.Climbed.colletionName)
            .getDocuments(FIDocument.Climbed.self)
            .catch { _ -> Just<[FIDocument.Climbed]> in
                return .init([])
            }
            .sink { [weak self] climbed in

                guard let self = self else { return }

                self.climbedList.append(contentsOf: climbed)
            }
            .store(in: &bindings)
    }

    private func setupBindings() {
        $climbedList
            .drop(while: { $0.isEmpty })
            .flatMap {
                FirestoreManager.db
                    .collection(FIDocument.User.colletionName)
                    .whereField("id", in: $0.map(\.climbedUserId))
                    .getDocuments(FIDocument.User.self)
            }
            .catch { _ -> Just<[FIDocument.User]> in
                return .init([])
            }
            .sink { [weak self] climbedUserList in

                guard let self = self else { return }

                self.climbedCellData = self.climbedList.compactMap { climbed -> ClimbedCellData? in

                    guard
                        let user = climbedUserList.first(where: { climbed.climbedUserId == $0.id })
                    else {
                        return nil
                    }

                    return .init(
                        climbed: climbed,
                        user: user,
                        isOwned: user.id == AuthManager.uid
                    )
                }
            }
            .store(in: &bindings)
    }

    func deleteClimbed(
        climbed: FIDocument.Climbed,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let badge = FirestoreManager.db.batch()
        badge.deleteDocument(climbed.makeDocumentReference())
        badge.updateData(
            ["total": FieldValue.increment(-1.0), climbed.type.fieldName: FieldValue.increment(-1.0)],
            forDocument: climbed.totalNumberReference
        )
        badge.commit()
            .sink(
                receiveCompletion: { result in
                    switch result {
                        case .finished:
                            completion(.success(()))

                        case .failure(let error):
                            completion(.failure(error))

                    }
                },
                receiveValue: {}
            )
            .store(in: &bindings)
    }
}
