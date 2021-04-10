//
//  CourseConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Combine
import Foundation

class CourseConfirmViewModel {
    
    let rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure
    let courseName: String
    let grade: FIDocument.Course.Grade
    let shape: Set<FIDocument.Course.Shape>
    let header: IdentifiableData
    let images: [IdentifiableData]
    let desc: String
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var courseUploadState: StoreUploadState = .stanby
    @Published private(set) var addIdState: StoreUploadState = .stanby

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    
    init(
        rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure,
        courseName: String,
        grade: FIDocument.Course.Grade,
        shape: Set<FIDocument.Course.Shape>,
        header: IdentifiableData,
        images: [IdentifiableData],
        desc: String
    ) {
        self.rockHeaderStructure = rockHeaderStructure
        self.courseName = courseName
        self.grade = grade
        self.shape = shape
        self.header = header
        self.images = images
        self.desc = desc
        
        bindImageUploader()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &$imageUploadState)
    }
    
    func uploadImages() {

        uploader.addData(
            data: header.data,
            reference: StorageManager.makeHeaderImageReference(
                parent: FINameSpace.Course.self,
                child: courseName
            )
        )

        images.forEach {
            uploader.addData(
                data: $0.data,
                reference: StorageManager.makeNormalImageReference(
                    parent: FINameSpace.Course.self,
                    child: courseName
                )
            )
        }
        
        uploader.start()
    }
    
    func registerCourse() {
        
        courseUploadState = .loading

        let badge = FirestoreManager.db.batch()

        let course = FIDocument.Course(
            parentPath: rockHeaderStructure.rock.makeDocumentReference().path,
            name: courseName,
            desc: desc,
            grade: grade,
            shape: shape,
            registedUserReference: AuthManager.getAuthUserReference()
        )
        let courseDocumentReference = course.makeDocumentReference()
        badge.setData(course.dictionary, forDocument: courseDocumentReference)

        let totalClimbedNumber = FIDocument.TotalClimbedNumber(
            parentCourseId: course.id,
            parentPath: courseDocumentReference.path
        )
        badge.setData(totalClimbedNumber.dictionary, forDocument: totalClimbedNumber.makeDocumentReference())

        badge.commit()
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.courseUploadState = .finish

                        case let .failure(error):
                            self.courseUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)

    }
}
