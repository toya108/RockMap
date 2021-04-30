//
//  CourseConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Combine
import Foundation

protocol CourseConfirmViewModelModelProtocol: ViewModelProtocol {
    var input: CourseConfirmViewModel.Input { get }
    var output: CourseConfirmViewModel.Output { get }
}

class CourseConfirmViewModel: CourseConfirmViewModelModelProtocol {

    var input: Input = .init()
    var output: Output = .init()
    
    let rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure
    let courseDocument: FIDocument.Course
    let header: IdentifiableData
    let images: [IdentifiableData]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    
    init(
        rockHeaderStructure: CourseRegisterViewModel.RockHeaderStructure,
        courseDocument: FIDocument.Course,
        header: IdentifiableData,
        images: [IdentifiableData]
    ) {
        self.rockHeaderStructure = rockHeaderStructure
        self.courseDocument = courseDocument
        self.header = header
        self.images = images
        bindImageUploader()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)
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
        
        output.courseUploadState = .loading

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
                            self.output.courseUploadState = .finish

                        case let .failure(error):
                            self.output.courseUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)

    }
}

extension CourseConfirmViewModel {

    struct Input {}

    final class Output {
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var courseUploadState: LoadingState = .stanby
    }
}
