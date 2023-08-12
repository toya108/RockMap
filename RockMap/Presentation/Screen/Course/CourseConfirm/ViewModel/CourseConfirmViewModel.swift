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
            .asyncSink(receiveValue: self.uploadImages)
            .store(in: &self.bindings)

        self.input.registerCourseSubject
            .asyncSink(receiveValue: self.registerCourse)
            .store(in: &self.bindings)
    }

    private var uploadImages: () async -> Void {{ [weak self] in

        guard let self = self else { return }

        do {

            try await withThrowingTaskGroup(of: Void.self) { group in

                group.addTask { [weak self] in

                    guard let self = self else { return }

                    try await self.writeImageUsecase.write(
                        data: self.header.updateData,
                        shouldDelete: self.header.shouldDelete,
                        image: self.header.image
                    ) {
                        .course
                        self.course.id
                        self.header.imageType
                    }
                }

                for image in self.images {
                    group.addTask { [weak self] in

                        guard let self = self else { return }

                        try await self.writeImageUsecase.write(
                            data: image.updateData,
                            shouldDelete: image.shouldDelete,
                            image: image.image
                        ) {
                            .course
                            self.course.id
                            Entity.Image.ImageType.normal
                            AuthManager.shared.uid
                        }
                    }
                }

                while let _ = try await group.next() {}
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in

                guard let self = self else { return }

                self.output.imageUploadState = .finish(content: ())
            }
        } catch {
            self.output.imageUploadState = .failure(error)
        }
    }}

    private var registerCourse: () async -> Void {{ [weak self] in

        guard let self = self else { return }

        self.output.courseUploadState = .loading

        switch self.registerType {
            case .create:
                await self.createCourse()

            case .edit:
                await self.editCourse()
        }
    }}

    private func createCourse() async {
        do {
            try await self.setCourseUsecase.set(course: self.course)
            self.output.courseUploadState = .finish(content: ())
        } catch {
            self.output.courseUploadState = .failure(error)
        }
    }

    private func editCourse() async {
        do {
            try await self.updateCourseUsecase.update(from: self.course)
            self.output.courseUploadState = .finish(content: ())
        } catch {
            self.output.courseUploadState = .failure(error)
        }
    }
}

extension CourseConfirmViewModel {
    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerCourseSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: LoadingState<Void> = .standby
        @Published var courseUploadState: LoadingState<Void> = .standby
    }
}
