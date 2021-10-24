import Auth
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
    private let writeImageUsecase = Usecase.Image.Write()

    private var bindings = Set<AnyCancellable>()

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
        self.bindInput()
    }

    private func bindInput() {
        self.input.uploadImageSubject
            .sink(receiveValue: self.uploadImages)
            .store(in: &self.bindings)

        self.input.registerCourseSubject
            .sink(receiveValue: self.registerCourse)
            .store(in: &self.bindings)
    }

    private var uploadImages: () -> Void {{ [weak self] in

        guard let self = self else { return }

        let writeHeader = self.writeImageUsecase.write(
            data: self.header.updateData,
            shouldDelete: self.header.shouldDelete,
            image: self.header.image
        ) {
            .course
            self.course.id
            self.header.imageType
        }

        let writeImages = self.images.map {
            self.writeImageUsecase.write(
                data: $0.updateData,
                shouldDelete: $0.shouldDelete,
                image: $0.image
            ) {
                .course
                self.course.id
                Entity.Image.ImageType.normal
                AuthManager.shared.uid
            }
        }

        let writeImagePublishers = [writeHeader] + writeImages

        Publishers.MergeMany(writeImagePublishers).collect()
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                print(error)
                self.output.imageUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in

                    guard let self = self else { return }

                    self.output.imageUploadState = .finish(content: ())
                }
            }
            .store(in: &self.bindings)
    }}

    private var registerCourse: () -> Void {{ [weak self] in

        guard let self = self else { return }

        self.output.courseUploadState = .loading

        switch self.registerType {
            case .create:
                self.createCourse()

            case .edit:
                self.editCourse()
        }
    }}

    private func createCourse() {
        self.setCourseUsecase.set(course: self.course)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.courseUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.courseUploadState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }

    private func editCourse() {
        self.updateCourseUsecase.update(from: self.course)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.courseUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.courseUploadState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }
}

extension CourseConfirmViewModel {
    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerCourseSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var courseUploadState: LoadingState<Void> = .stanby
    }
}
