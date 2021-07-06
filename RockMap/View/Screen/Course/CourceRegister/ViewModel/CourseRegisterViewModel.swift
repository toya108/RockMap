//
//  CourseRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import Combine
import Foundation

protocol CourseRegisterViewModelProtocol: ViewModelProtocol {
    var input: CourseRegisterViewModel.Input { get }
    var output: CourseRegisterViewModel.Output { get }
}

class CourseRegisterViewModel: CourseRegisterViewModelProtocol {

    typealias HeaderValidator = HeaderImageValidator<FIDocument.Course>

    var input: Input = .init()
    var output: Output = .init()

    let registerType: RegisterType

    private var bindings = Set<AnyCancellable>()

    init(registerType: RegisterType) {
        self.registerType = registerType
        bindInput()
        bindOutput()

        guard
            case let .edit(course) = registerType
        else {
            return
        }

        input.courseNameSubject.send(course.name)
        input.courseDescSubject.send(course.desc)
        input.gradeSubject.send(course.grade)
        input.shapeSubject.send(course.shape)
        input.courseNameSubject.send(course.name)
        fetchCourseStorage(courseId: course.id)
    }

    private func bindInput() {
        input.courseNameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$courseName)

        input.courseDescSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$courseDesc)

        input.gradeSubject
            .removeDuplicates()
            .assign(to: &output.$grade)

        input.shapeSubject
            .sink { [weak self] shapes in

                guard let self = self else { return }

                shapes.forEach {
                    if self.output.shapes.contains($0) {
                        self.output.shapes.remove($0)
                    } else {
                        self.output.shapes.insert($0)
                    }
                }
            }
            .store(in: &bindings)

        input.setImageSubject
            .sink(receiveValue: setImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)
    }

    private func bindOutput() {
        output.$courseName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$courseNameValidationResult)

        output.$images
            .dropFirst()
            .map { RockImageValidator().validate($0.filter(\.shouldDelete)) }
            .assign(to: &output.$courseImageValidationResult)

        output.$header
            .dropFirst()
            .map { HeaderValidator().validate($0) }
            .assign(to: &output.$headerImageValidationResult)
    }

    private func fetchCourseStorage(courseId: String) {
        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Course.self,
                documentId: courseId,
                imageType: .header
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { .init(storageReference: $0, imageType: .header) }
            .assign(to: &output.$header)

        StorageManager
            .getNormalImagePrefixes(
                destinationDocument: FINameSpace.Course.self,
                documentId: courseId
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .flatMap { $0.getReferences().catch { _ in Empty() } }
            .map {
                $0.map { .init(storageReference: $0, imageType: .normal) }
            }
            .assign(to: &self.output.$images)
    }

    private func setImage(data: Data, imageType: ImageType) {

        switch imageType {
            case .normal:
                output.images.append(.init(updateData: data, imageType: imageType))

            case .header:
                output.header.updateData = data
                output.header.shouldDelete = false

            case .icon:
                break
        }
    }

    private func deleteImage(_ image: CrudableImage<FIDocument.Course>) {
        switch image.imageType {
            case .header:
                output.header.updateData = nil

                if output.header.storageReference != nil {
                    output.header.shouldDelete = true
                }

            case .normal:
                if let index = output.images.firstIndex(of: image) {
                    if output.images[index].storageReference != nil {
                        output.images[index].updateData = nil
                        output.images[index].shouldDelete = true
                    } else {
                        output.images.remove(at: index)
                    }
                }

            default:
                break
        }
    }
    
    func callValidations() -> Bool {
        if !output.headerImageValidationResult.isValid {
            output.headerImageValidationResult = HeaderValidator().validate(output.header)
        }
        if !output.courseImageValidationResult.isValid {
            let images = output.images.filter(\.shouldDelete)
            output.courseImageValidationResult = RockImageValidator().validate(images)
        }
        if !output.courseNameValidationResult.isValid {
            output.courseNameValidationResult = CourseNameValidator().validate(output.courseName)
        }

        return [
            output.courseNameValidationResult,
            output.courseImageValidationResult,
            output.headerImageValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    func makeCourseDocument() -> FIDocument.Course {
        switch registerType {
            case let .create(rock):
                return .init(
                    parentPath: AuthManager.shared.authUserReference?.path ?? "",
                    name: output.courseName,
                    desc: output.courseDesc,
                    grade: output.grade,
                    shape: output.shapes,
                    parentRockName: rock.name,
                    parentRockId: rock.id,
                    registeredUserId: AuthManager.shared.uid
                )
                
            case var .edit(course):
                course.name = output.courseName
                course.desc = output.courseDesc
                course.grade = output.grade
                course.shape = output.shapes
                return course
        }
    }
}

extension CourseRegisterViewModel {

    enum RegisterType {
        case create(FIDocument.Rock)
        case edit(FIDocument.Course)

        var name: String {
            switch self {
                case .create:
                    return "作成"
                case .edit:
                    return "編集"
            }
        }
    }

}

extension CourseRegisterViewModel {

    struct Input {
        let courseNameSubject = PassthroughSubject<String?, Never>()
        let courseDescSubject = PassthroughSubject<String?, Never>()
        let gradeSubject = PassthroughSubject<FIDocument.Course.Grade, Never>()
        let shapeSubject = PassthroughSubject<Set<FIDocument.Course.Shape>, Never>()
        let setImageSubject = PassthroughSubject<(Data, ImageType), Never>()
        let deleteImageSubject = PassthroughSubject<(CrudableImage<FIDocument.Course>), Never>()
    }

    final class Output {
        @Published var courseName = ""
        @Published var courseDesc = ""
        @Published var grade = FIDocument.Course.Grade.q10
        @Published var shapes = Set<FIDocument.Course.Shape>()
        @Published var header: CrudableImage<FIDocument.Course> = .init(imageType: .header)
        @Published var images: [CrudableImage<FIDocument.Course>] = []
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
