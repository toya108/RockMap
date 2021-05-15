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
    
    let registerType: CourseRegisterViewModel.RegisterType
    let courseDocument: FIDocument.Course
    let header: ImageDataKind
    let images: [ImageDataKind]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    
    init(
        registerType: CourseRegisterViewModel.RegisterType,
        courseDocument: FIDocument.Course,
        header: ImageDataKind,
        images: [ImageDataKind]
    ) {
        self.registerType = registerType
        self.courseDocument = courseDocument
        self.header = header
        self.images = images
        bindImageUploader()
        bindInput()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)
    }

    private func bindInput() {
        input.uploadImageSubject
            .sink(receiveValue: uploadImages)
            .store(in: &bindings)

        input.registerCourseSubject
            .sink(receiveValue: registerCourse)
            .store(in: &bindings)
    }
    
    private func uploadImages() {
        prepareHeaderUploading()
        prepareImagesUploading()
        uploader.start()
    }

    private func prepareHeaderUploading() {
        let headerReference = StorageManager.makeImageReferenceForUpload(
            destinationDocument: FINameSpace.Course.self,
            documentId: courseDocument.id,
            imageType: .header
        )
        switch header {
            case .data(let data):
                uploader.addData(
                    data: data.data,
                    reference: headerReference
                )
            case .storage(let storage):

                guard let updateData = storage.updateData else { return }

                storage.storageReference.delete()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {}
                    )
                    .store(in: &bindings)

                uploader.addData(
                    data: updateData,
                    reference: headerReference
                )
        }
    }

    private func prepareImagesUploading() {
        images.forEach { imageDataKind in
            switch imageDataKind {
                case .data(let data):
                    uploader.addData(
                        data: data.data,
                        reference: StorageManager.makeImageReferenceForUpload(
                            destinationDocument: FINameSpace.Course.self,
                            documentId: courseDocument.id,
                            imageType: .normal
                        )
                    )
                case .storage(let storage):

                    guard storage.shouldUpdate else { return }

                    storage.storageReference.delete()
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: {}
                        )
                        .store(in: &bindings)
            }
        }
    }
    
    private func registerCourse() {
        output.courseUploadState = .loading

        switch registerType {
            case .create:
                createCourse()

            case .edit:
                editCourse()
        }
    }

    private func createCourse() {
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
                            self.output.courseUploadState = .finish(content: ())

                        case let .failure(error):
                            self.output.courseUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)
    }

    private func editCourse() {
        courseDocument.makeDocumentReference()
            .updateData(courseDocument.dictionary)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.output.courseUploadState = .finish(content: ())

                        case let .failure(error):
                            self.output.courseUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)
    }
}

extension CourseConfirmViewModel {

    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerCourseSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var courseUploadState: LoadingState<Void> = .stanby
    }
}
