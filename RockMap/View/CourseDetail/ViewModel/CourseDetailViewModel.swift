//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine
import Foundation

final class CourseDetailViewModel: ViewModelProtocol {
    
    @Published var course: FIDocument.Course
    @Published var courseHeaderImageReference: StorageManager.Reference?
    @Published var courseImageReferences: [StorageManager.Reference] = []
    @Published var courseName = ""
    @Published var courseId = ""
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
        courseId = course.id
        registeredDate = course.createdAt
        fetchRegisterdUser()
        shape = course.shape
        desc = course.desc
    }
    
    private func setupBindings() {
        $courseId
            .drop(while: { $0.isEmpty })
            .map {
                StorageManager.makeReference(parent: FINameSpace.Course.self, child: $0)
            }
            .flatMap { StorageManager.getHeaderReference($0) }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &$courseHeaderImageReference)

        $courseId
            .drop(while: { $0.isEmpty })
            .map {
                StorageManager.makeReference(parent: FINameSpace.Course.self, child: $0)
            }
            .flatMap { StorageManager.getNormalImagePrefixes($0) }
            .catch { _ -> Just<[StorageManager.Reference]> in
                return .init([])
            }
            .sink { prefixes in
                prefixes
                    .map { $0.getReferences() }
                    .forEach {
                        $0.catch { _ -> Just<[StorageManager.Reference]> in
                            return .init([])
                        }
                        .sink { [weak self] references in

                            guard let self = self else { return }

                            self.courseImageReferences.append(contentsOf: references)
                        }
                        .store(in: &self.bindings)
                    }
            }
            .store(in: &bindings)
    }

    private func fetchRegisterdUser() {
        FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(course.registedUserId)
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

        guard let totalClimbedNumber = totalClimbedNumber else { return }

        let badge = FirestoreManager.db.batch()

        let climbed = FIDocument.Climbed(
            parentCourseReference: course.makeDocumentReference(),
            totalNumberReference: totalClimbedNumber.makeDocumentReference(),
            parentPath: course.makeDocumentReference().path,
            climbedDate: climbedDate,
            type: type,
            climbedUserId: AuthManager.shared.uid
        )
        badge.setData(climbed.dictionary, forDocument: climbed.makeDocumentReference())

        badge.updateData(
            [
                "total": FirestoreManager.Value.increment(1.0),
                type.fieldName: FirestoreManager.Value.increment(1.0)
            ],
            forDocument: totalClimbedNumber.makeDocumentReference()
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

