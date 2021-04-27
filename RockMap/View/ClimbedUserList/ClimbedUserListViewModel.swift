//
//  ClimbedUserListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import Combine
import Foundation

class ClimbedUserListViewModel {

    struct ClimbedCellData: Hashable {
        var climbed: FIDocument.Climbed
        let user: FIDocument.User
        let isOwned: Bool
    }

    private let course: FIDocument.Course
    @Published private var climbedList: [FIDocument.Climbed] = []
    @Published var climbedCellData: [ClimbedCellData] = []
    private var bindings = Set<AnyCancellable>()

    init(course: FIDocument.Course) {
        self.course = course
        fetchClimbed()
        setupBindings()
    }

    func fetchClimbed() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Climbed.colletionName)
            .whereField("parentCourseId", in: [course.id])
            .order(by: "climbedDate")
            .getDocuments(FIDocument.Climbed.self)
            .catch { _ -> Just<[FIDocument.Climbed]> in
                return .init([])
            }
            .assign(to: &$climbedList)
    }

    private func setupBindings() {
        $climbedList
            .drop(while: { $0.isEmpty })
            .flatMap {
                FirestoreManager.db
                    .collection(FIDocument.User.colletionName)
                    .whereField("id", in: $0.map(\.registeredUserId))
                    .getDocuments(FIDocument.User.self)
            }
            .catch { _ -> Just<[FIDocument.User]> in
                return .init([])
            }
            .sink { [weak self] climbedUserList in

                guard let self = self else { return }

                self.climbedCellData = self.climbedList.compactMap { climbed -> ClimbedCellData? in

                    guard
                        let user = climbedUserList.first(where: { climbed.registeredUserId == $0.id })
                    else {
                        return nil
                    }

                    return .init(
                        climbed: climbed,
                        user: user,
                        isOwned: user.id == AuthManager.shared.uid
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
            [
                "total": FirestoreManager.Value.increment(-1.0),
                climbed.type.fieldName: FirestoreManager.Value.increment(-1.0)
            ],
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

    func updateClimbedData(
        id: String,
        date: Date,
        type: FIDocument.Climbed.ClimbedRecordType
    ) {
        guard
            let index = climbedCellData.firstIndex(where: { $0.climbed.id == id })
        else {
            return
        }

        climbedCellData[index].climbed.climbedDate = date
        climbedCellData[index].climbed.type = type

        climbedCellData.sort(
            by: { $0.climbed.climbedDate < $1.climbed.climbedDate }
        )

    }
}
