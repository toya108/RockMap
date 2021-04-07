//
//  ClimbedUserListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import Combine

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
        updateClimbed(course: course)
        setupBindings()
    }

    private func updateClimbed(course: FIDocument.Course) {
        let climbedPath = [
            FirestoreManager.makeParentPath(parent: course),
            FIDocument.Climbed.colletionName
        ].joined(separator: "/")

        FirestoreManager.db.collection(climbedPath).getDocuments { [weak self] snap, error in

            guard let self = self else { return }

            if let _ = error {
                return
            }

            guard let snap = snap else { return }

           let climbedList  = snap.documents
                .map { $0.data() }
                .compactMap { FIDocument.Climbed.initializeDocument(json: $0) }

            self.climbedList.append(contentsOf: climbedList)
        }
    }

    private func setupBindings() {
        $climbedList
            .drop(while: { $0.isEmpty })
            .sink { climbedList in
                FirestoreManager.db
                    .collection(FIDocument.User.colletionName)
                    .whereField("id", in: climbedList.map(\.climbedUserId))
                    .getDocuments { snap, error in

                        if let _ = error {
                            return
                        }

                        guard let snap = snap else { return }

                        let climbedUserList = snap.documents.compactMap {
                            FIDocument.User.initializeDocument(json: $0.data())
                        }
                        self.climbedCellData = self.climbedList.compactMap {
                            climbed -> ClimbedCellData? in

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
            }
            .store(in: &bindings)
    }

    func deleteClimbed(climbed: FIDocument.Climbed, completion: @escaping (Error?) -> Void) {
        FirestoreManager.db.document(FirestoreManager.makeParentPath(parent: climbed)).delete(completion: completion)
    }
}
