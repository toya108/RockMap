
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
    let header: CrudableImageV2
    let images: [CrudableImageV2]
    private(set) var course: Entity.Course
    private let setCourseUsecase = Usecase.Course.Set()
    private let updateCourseUsecase = Usecase.Course.Update()
    private let writeImageUsecase = Usecase.Image.Write()

    private var bindings = Set<AnyCancellable>()

    init(
        registerType: CourseRegisterViewModel.RegisterType,
        course: Entity.Course,
        header: CrudableImageV2,
        images: [CrudableImageV2]
    ) {
        self.registerType = registerType
        self.course = course
        self.header = header
        self.images = images
        bindInput()
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

        let writeHeader = writeImageUsecase.write(
            data: header.updateData,
            shouldDelete: header.shouldDelete,
            image: header.image
        ) {
            .course
            course.id
            header.imageType
        }

        let writeImages = images.map {
            writeImageUsecase.write(
                data: $0.updateData,
                shouldDelete: $0.shouldDelete,
                image: $0.image
            ) {
                .course
                course.id
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
            .store(in: &bindings)
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
        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var courseUploadState: LoadingState<Void> = .stanby
    }
}
