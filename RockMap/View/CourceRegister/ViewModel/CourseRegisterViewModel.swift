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
            .map { RockImageValidator().validate($0) }
            .assign(to: &output.$courseImageValidationResult)

        output.$header
            .dropFirst()
            .map { RockHeaderImageValidator().validate($0) }
            .assign(to: &output.$headerImageValidationResult)
    }

    private func fetchCourseStorage(courseId: String) {
        let courseStorageReference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: courseId
        )
        StorageManager
            .getHeaderReference(courseStorageReference)
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .compactMap { $0 }
            .map { ImageDataKind.storage(.init(storageReference: $0)) }
            .assign(to: &output.$header)

        StorageManager.getNormalImagePrefixes(courseStorageReference)
            .catch { _ -> Just<[StorageManager.Reference]> in
                return .init([])
            }
            .sink { [weak self] prefixes in

                guard let self = self else { return }

                prefixes
                    .map { $0.getReferences() }
                    .forEach {
                        $0.catch { _ -> Just<[StorageManager.Reference]> in
                            return .init([])
                        }
                        .map {
                            $0.map { ImageDataKind.storage(.init(storageReference: $0)) }
                        }
                        .assign(to: &self.output.$images)
                    }
            }
            .store(in: &bindings)
    }

    private func setImage(_ imageStructure: ImageStructure) {
        switch imageStructure.imageType {
            case .header:
                setHeaderImage(kind: imageStructure.imageDataKind)

            case .normal:
                setNormalImage(kind: imageStructure.imageDataKind)
        }
    }

    private func setHeaderImage(kind: ImageDataKind) {
        switch output.header {
            case .data, .none:
                output.header = kind

            case .storage(var storage):
                storage.updateData = kind.data?.data
                storage.shouldUpdate = true
                output.header?.update(.storage(storage))
        }
    }

    private func setNormalImage(kind: ImageDataKind) {
        self.output.images.append(kind)
    }

    private func deleteImage(_ imageStructure: ImageStructure) {
        switch imageStructure.imageType {
            case .header:
                deleteHeaderImage()

            case .normal:
                deleteNormalImage(target: imageStructure.imageDataKind)
        }
    }

    private func deleteHeaderImage() {
        switch output.header {
            case .data:
                output.header = nil

            case .storage:
                output.header?.toggleStorageUpdateFlag()

            default:
                break
        }
    }

    private func deleteNormalImage(target: ImageDataKind) {

        guard
            let index = self.output.images.firstIndex(of: target)
        else {
            return
        }

        switch target {
            case .data:
                self.output.images.remove(at: index)

            case .storage:
                self.output.images[index].toggleStorageUpdateFlag()
        }

    }
    
    func callValidations() -> Bool {
        if !output.headerImageValidationResult.isValid {
            output.headerImageValidationResult = RockHeaderImageValidator().validate(output.header)
        }
        if !output.courseImageValidationResult.isValid {
            output.courseImageValidationResult = RockImageValidator().validate(output.images)
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
            case let .create(rockHeader):
                return .init(
                    parentPath: AuthManager.shared.authUserReference?.path ?? "",
                    name: output.courseName,
                    desc: output.courseDesc,
                    grade: output.grade,
                    shape: output.shapes,
                    parentRockName: rockHeader.rock.name,
                    parentRockId: rockHeader.rock.id,
                    registedUserId: AuthManager.shared.uid
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

    struct RockHeaderStructure: Hashable {
        let rock: FIDocument.Rock
        let rockImageReference: StorageManager.Reference
    }

    enum RegisterType {
        case create(RockHeaderStructure)
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
        let setImageSubject = PassthroughSubject<(ImageStructure), Never>()
        let deleteImageSubject = PassthroughSubject<(ImageStructure), Never>()
    }

    final class Output {
        @Published var courseName = ""
        @Published var courseDesc = ""
        @Published var grade = FIDocument.Course.Grade.q10
        @Published var shapes = Set<FIDocument.Course.Shape>()
        @Published var header: ImageDataKind?
        @Published var images: [ImageDataKind] = []
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
