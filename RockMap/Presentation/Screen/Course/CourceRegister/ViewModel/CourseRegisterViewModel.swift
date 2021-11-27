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
        self.bindInput()
        self.bindOutput()

        guard
            case let .edit(course) = registerType
        else {
            return
        }

        self.input.courseNameSubject.send(course.name)
        self.input.courseDescSubject.send(course.desc)
        self.input.gradeSubject.send(course.grade)
        self.input.shapeSubject.send(course.shape)
        self.input.courseNameSubject.send(course.name)
        self.fetchCourseStorage(courseId: course.id)
    }

    private func bindInput() {
        self.input.courseNameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$courseName)

        self.input.courseDescSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$courseDesc)

        self.input.gradeSubject
            .removeDuplicates()
            .assign(to: &self.output.$grade)

        self.input.shapeSubject
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
            .store(in: &self.bindings)

        self.input.setImageSubject
            .sink(receiveValue: self.setImage)
            .store(in: &self.bindings)

        self.input.deleteImageSubject
            .sink(receiveValue: self.deleteImage)
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$courseName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &self.output.$courseNameValidationResult)

        self.output.$images
            .dropFirst()
            .map { RockImageValidator().validate($0.filter(\.shouldDelete)) }
            .assign(to: &self.output.$courseImageValidationResult)

        self.output.$header
            .dropFirst()
            .map { HeaderValidator().validate($0) }
            .assign(to: &self.output.$headerImageValidationResult)
    }

    private func fetchCourseStorage(courseId: String) {
        Task {
            do {
                let header = try await self.fetchHeaderUsecase.fetch(id: courseId, destination: .course)
                self.output.header = .init(imageType: .header, image: header)
                let images = try await self.fetchImagesUsecase.fetch(id: courseId, destination: .course)
                self.output.images = images.map { CrudableImage(imageType: .normal, image: $0) }
            } catch {
                print(error)
            }
        }
    }

    private var setImage: (Data, Entity.Image.ImageType) -> Void {{ [weak self] data, imageType in

        guard let self = self else { return }

        switch imageType {
        case .normal:
            let newImage = CrudableImage(
                updateData: data,
                shouldDelete: false,
                imageType: .normal,
                image: .init()
            )
            self.output.images.append(newImage)

        case .header:
            self.output.header.updateData = data
            self.output.header.shouldDelete = false

        case .icon, .unhandle:
            break
        }
    }}

    private var deleteImage: (CrudableImage) -> Void {{ [weak self] crudableImage in

        guard let self = self else { return }

        switch crudableImage.imageType {
            case .header:
                self.output.header.updateData = nil

                if self.output.header.image.url != nil {
                    self.output.header.shouldDelete = true
                }

            case .normal:

                guard
                    let index = self.output.images.firstIndex(of: crudableImage)
                else {
                    return
                }
                
                if self.output.images[index].image.url != nil {
                    self.output.images[index].updateData = nil
                    self.output.images[index].shouldDelete = true
                } else {
                    self.output.images.remove(at: index)
                }

            case .icon, .unhandle:
                break
        }
    }}

    func callValidations() -> Bool {
        if !self.output.headerImageValidationResult.isValid {
            self.output.headerImageValidationResult = HeaderValidator().validate(self.output.header)
        }
        if !self.output.courseImageValidationResult.isValid {
            let images = self.output.images.filter(\.shouldDelete)
            self.output.courseImageValidationResult = RockImageValidator().validate(images)
        }
        if !self.output.courseNameValidationResult.isValid {
            self.output.courseNameValidationResult = CourseNameValidator()
                .validate(self.output.courseName)
        }

        return [
            self.output.courseNameValidationResult,
            self.output.courseImageValidationResult,
            self.output.headerImageValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    var courseEntity: Entity.Course {
        switch self.registerType {
        case let .create(rockHeader):
            return .init(
                id: UUID().uuidString,
                parentPath: AuthManager.shared.userPath,
                createdAt: Date(),
                updatedAt: nil,
                name: self.output.courseName,
                desc: self.output.courseDesc,
                grade: self.output.grade,
                shape: self.output.shapes,
                parentRockName: rockHeader.name,
                parentRockId: rockHeader.id,
                registeredUserId: AuthManager.shared.uid,
                headerUrl: nil,
                imageUrls: []
            )

        case var .edit(course):
            course.name = self.output.courseName
            course.desc = self.output.courseDesc
            course.grade = self.output.grade
            course.shape = self.output.shapes
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
        let deleteImageSubject = PassthroughSubject<CrudableImage, Never>()
    }

    final class Output {
        @Published var courseName = ""
        @Published var courseDesc = ""
        @Published var grade = Entity.Course.Grade.q10
        @Published var shapes = Set<Entity.Course.Shape>()
        @Published var header: CrudableImage = .init(imageType: .header)
        @Published var images: [CrudableImage] = []
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
