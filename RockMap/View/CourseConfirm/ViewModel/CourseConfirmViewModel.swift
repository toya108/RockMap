//
//  CourseConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Combine
import Foundation

class CourseConfirmViewModel: ViewModelProtocol {
    
    let rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure
    let courseName: String
    let grade: FIDocument.Course.Grade
    let shape: Set<FIDocument.Course.Shape>
    let header: IdentifiableData
    let images: [IdentifiableData]
    let desc: String
    private let courseDocument: FIDocument.Course

    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var courseUploadState: LoadingState = .stanby
    @Published private(set) var addIdState: LoadingState = .stanby

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

        courseDocument = FIDocument.Course(
            parentPath: AuthManager.shared.authUserReference?.path ?? "",
            name: courseName,
            desc: desc,
            grade: grade,
            shape: shape,
            parentRockName: rockHeaderStructure.rock.name,
            parentRockId: rockHeaderStructure.rock.id,
            registedUserId: AuthManager.shared.uid
        )
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
                child: courseDocument.id
            )
        )

        images.forEach {
            uploader.addData(
                data: $0.data,
                reference: StorageManager.makeNormalImageReference(
                    parent: FINameSpace.Course.self,
                    child: courseDocument.id
                )
            )
        }
        
        uploader.start()
    }
    
    func registerCourse() {
        
        courseUploadState = .loading

        let badge = FirestoreManager.db.batch()

        let courseDocumentReference = courseDocument.makeDocumentReference()
        badge.setData(courseDocument.dictionary, forDocument: courseDocumentReference)

        let totalClimbedNumber = FIDocument.TotalClimbedNumber(
            parentCourseReference: courseDocument.makeDocumentReference(),
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
