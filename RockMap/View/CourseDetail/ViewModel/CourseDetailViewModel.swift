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
        
    }
    
    private func setupBindings() {
        $courseName
            .drop(while: { $0.isEmpty })
            .map {
                StorageManager.makeReference(parent: FINameSpace.Course.self, child: $0)
            }
            .flatMap { StorageManager.getHeaderReference($0) }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &$courseImageReference)
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
        course.makeDocumentReference()
            .collection(FIDocument.TotalClimbedNumber.colletionName)
            .publisher(as: FIDocument.TotalClimbedNumber.self)
            .catch { _ -> Just<[FIDocument.TotalClimbedNumber]> in
                return .init([])
            }
            .sink { [weak self] totalClimbedNumberDocuments in
                guard
                    let self = self,
                    let totalClimbedNumber = totalClimbedNumberDocuments.first
                else { return }

                self.totalClimbedNumber = totalClimbedNumber
            }
            .store(in: &bindings)
    }
    
    func registerClimbed(
        climbedDate: Date,
        type: FIDocument.Climbed.ClimbedRecordType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let badge = FirestoreManager.db.batch()

        let climbed = FIDocument.Climbed(
            parentCourseReference: course.makeDocumentReference(),
            parentPath: course.makeDocumentReference().path,
            climbedDate: climbedDate,
            type: type,
            climbedUserId: AuthManager.uid
        )
        badge.setData(climbed.dictionary, forDocument: climbed.makeDocumentReference())

        if let totalClimbedNumber = totalClimbedNumber {
            badge.updateData(
                ["total": FieldValue.increment(1.0), type.fieldName: FieldValue.increment(1.0)],
                forDocument: totalClimbedNumber.makeDocumentReference()
            )
        }

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

