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
    let header: CrudableImage<FIDocument.Course>
    let images: [CrudableImage<FIDocument.Course>]
    private(set) var courseDocument: FIDocument.Course

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    
    init(
        registerType: CourseRegisterViewModel.RegisterType,
        courseDocument: FIDocument.Course,
        header: CrudableImage<FIDocument.Course>,
        images: [CrudableImage<FIDocument.Course>]
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
        uploader.addData(image: header, id: courseDocument.id)
        images.forEach { uploader.addData(image: $0, id: courseDocument.id) }
        uploader.start()
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
        courseDocument.makeDocumentReference()
            .setData(from: courseDocument)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.courseUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.courseUploadState = .finish(content: ())
            }
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
