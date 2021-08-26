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
    let header: CrudableImage
    let images: [CrudableImage]
    private(set) var course: Entity.Course
    private let setCourseUsecase = Usecase.Course.Set()
    private let updateCourseUsecase = Usecase.Course.Update()

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    
    init(
        registerType: CourseRegisterViewModel.RegisterType,
        course: Entity.Course,
        header: CrudableImage,
        images: [CrudableImage]
    ) {
        self.registerType = registerType
        self.course = course
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
        uploader.addData(
            image: header,
            id: course.id,
            documentType: FINameSpace.Course.self
        )
        images.forEach {
            uploader.addData(
                image: $0,
                id: course.id,
                documentType: FINameSpace.Course.self
            )
        }
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
        setCourseUsecase.set(course: course)
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
        updateCourseUsecase.update(from: self.course)
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
