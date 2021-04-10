//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine
import Foundation
import FirebaseFirestore

final class CourseDetailViewModel {
    
    @Published var course: FIDocument.Course
    @Published var courseImageReference: StorageManager.Reference?
    @Published var courseName = ""
    @Published var registeredUser: FIDocument.User?
    @Published var registeredDate: Date?
    @Published var totalClimbedNumber: FIDocument.TotalClimbedNumber?
    @Published var shape: Set<FIDocument.Course.Shape> = []
    @Published var desc: String = ""

    private var totalNumberListener: ListenerRegistration?
    private var bindings = Set<AnyCancellable>()
    
    init(course: FIDocument.Course) {
        self.course = course
        
        setupBindings()
        listenToTotalClimbedNumber()
        
        courseName = course.name
        registeredDate = course.createdAt
        fetchRegisterdUser(reference: course.registedUserReference)
        shape = course.shape
        desc = course.desc
    }

    deinit {
        totalNumberListener?.remove()
    }
    
    private func setupBindings() {
        $courseName
            .drop(while: { $0.isEmpty })
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                let reference = StorageManager.makeReference(
                    parent: FINameSpace.Course.self,
                    child: name
                )
                
                StorageManager.getHeaderReference(reference: reference) { result in
                    
                    guard
                        case let .success(reference) = result
                    else {
                        return
                    }
                    
                    self.courseImageReference = reference
                }
            }
            .store(in: &bindings)
    }

    private func fetchRegisterdUser(reference: DocumentRef) {
        reference
            .getDocument(FIDocument.User.self)
            .catch { _ -> Just<FIDocument.User?> in
                return .init(nil)
            }
            .assign(to: &$registeredUser)
    }

    private func listenToTotalClimbedNumber() {

        let climedNumberPath = [
            FirestoreManager.makeParentPath(parent: course),
            FIDocument.TotalClimbedNumber.colletionName
        ].joined(separator: "/")

        FirestoreManager.db.collection(climedNumberPath).getDocuments { [weak self] snap, error in

            guard let self = self else { return }

            if let _ = error {
                return
            }

            guard
                let document = FIDocument.TotalClimbedNumber.initializeDocument(
                    json: snap?.documents.first?.data() ?? [:]
                )
            else {
                return
            }

            self.totalClimbedNumber = document

            let listener = FirestoreManager.db
                .collection(climedNumberPath)
                .document(document.id)
                .addSnapshotListener { [weak self] snap, error in

                    if let error = error {
                        return
                    }

                    guard
                        let self = self,
                        let snap = snap,
                        let totalClimbed = FIDocument.TotalClimbedNumber.initializeDocument(json: snap.data() ?? [:])
                    else {
                        return
                    }

                    self.totalClimbedNumber = totalClimbed
                }
            self.totalNumberListener = listener
        }
    }
    
    func registerClimbed(
        climbedDate: Date,
        type: FIDocument.Climbed.ClimbedRecordType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let parentPath = FirestoreManager.makeParentPath(parent: course)
        let climbed = FIDocument.Climbed(
            parentCourseReference: course.makeDocumentReference(),
            parentPath: parentPath,
            climbedDate: climbedDate,
            type: type,
            climbedUserId: AuthManager.uid
        )

        FirestoreManager.set(
            parentPath: parentPath,
            documentId: climbed.id,
            document: climbed
        ) { [weak self] result in

            guard let self = self else { return }

            switch result {
                case .success:
                    
                    self.incrementTotalClimbedNumber(type: climbed.type)
                    completion(.success(()))

                case let .failure(error):
                    break

            }
        }
    }

    private func incrementTotalClimbedNumber(type: FIDocument.Climbed.ClimbedRecordType) {

        guard let totalClimbedNumber = totalClimbedNumber else { return }

        let climebedNumberPath = [
            totalClimbedNumber.parentPath,
            FIDocument.TotalClimbedNumber.colletionName
        ].joined(separator: "/")

        let totalClimedNumberRef = FirestoreManager.db
            .collection(climebedNumberPath)
            .document(totalClimbedNumber.id)

        totalClimedNumberRef.setData(
            ["total": FieldValue.increment(1.0), type.fieldName: FieldValue.increment(1.0)],
            merge: true
        )
    }
}

