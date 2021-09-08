
import Auth
import Combine
import Foundation

protocol CourseRegisterViewModelProtocol: ViewModelProtocol {
    var input: CourseRegisterViewModel.Input { get }
    var output: CourseRegisterViewModel.Output { get }
}

class CourseRegisterViewModel: CourseRegisterViewModelProtocol {

    typealias HeaderValidator = HeaderImageValidator

    var input: Input = .init()
    var output: Output = .init()

    let registerType: RegisterType

    private let fetchHeaderUsecase = Usecase.Image.Fetch.Header()
    private let fetchImagesUsecase = Usecase.Image.Fetch.Normal()
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
        fetchHeaderUsecase.fetch(id: courseId, destination: .course)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { CrudableImageV2(imageType: .header, image: $0) }
            .assign(to: &output.$header)

        fetchImagesUsecase.fetch(id: courseId, destination: .course)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map {
                $0.map { .init(imageType: .normal, image: $0) }
            }
            .assign(to: &self.output.$images)
    }

    private func setImage(data: Data, imageType: Entity.Image.ImageType) {

        switch imageType {
            case .normal:
                let newImage = CrudableImageV2(
                    updateData: data,
                    shouldDelete: false,
                    imageType: .normal,
                    image: .init()
                )
                output.images.append(newImage)

            case .header:
                output.header.updateData = data
                output.header.shouldDelete = false

            case .icon, .unhandle:
                break
        }
    }

    private func deleteImage(_ crudableImage: CrudableImageV2) {
        switch crudableImage.imageType {
            case .header:
                output.header.updateData = nil

                if output.header.image.url != nil {
                    output.header.shouldDelete = true
                }

            case .normal:
                if let index = output.images.firstIndex(of: crudableImage) {
                    if output.images[index].image.url != nil {
                        output.images[index].updateData = nil
                        output.images[index].shouldDelete = true
                    } else {
                        output.images.remove(at: index)
                    }
                }

            case .icon, .unhandle:
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

    var courseEntity: Entity.Course {
        switch registerType {
            case let .create(rockHeader):
                return .init(
                    id: UUID().uuidString,
                    parentPath: AuthManager.shared.userPath,
                    createdAt: Date(),
                    updatedAt: nil,
                    name: output.courseName,
                    desc: output.courseDesc,
                    grade: output.grade,
                    shape: output.shapes,
                    parentRockName: rockHeader.name,
                    parentRockId: rockHeader.id,
                    registeredUserId: AuthManager.shared.uid,
                    headerUrl: nil,
                    imageUrls: []
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

    struct RockHeader {
        let name: String
        let id: String
        let headerUrl: URL?
    }

    enum RegisterType {
        case create(RockHeader)
        case edit(Entity.Course)

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
        let gradeSubject = PassthroughSubject<Entity.Course.Grade, Never>()
        let shapeSubject = PassthroughSubject<Set<Entity.Course.Shape>, Never>()
        let setImageSubject = PassthroughSubject<(Data, Entity.Image.ImageType), Never>()
        let deleteImageSubject = PassthroughSubject<(CrudableImageV2), Never>()
    }

    final class Output {
        @Published var courseName = ""
        @Published var courseDesc = ""
        @Published var grade = Entity.Course.Grade.q10
        @Published var shapes = Set<Entity.Course.Shape>()
        @Published var header: CrudableImageV2 = .init(imageType: .header)
        @Published var images: [CrudableImageV2] = []
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
