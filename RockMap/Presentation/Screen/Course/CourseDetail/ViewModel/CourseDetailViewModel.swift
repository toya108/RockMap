import Combine
import Foundation
import Utilities

protocol CourseDetailViewModelProtocol: ViewModelProtocol {
    var input: CourseDetailViewModel.Input { get }
    var output: CourseDetailViewModel.Output { get }
}

final class CourseDetailViewModel: CourseDetailViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()

    let course: Entity.Course
    private let listenTotalClimbedNumberUsecase = Usecase.TotalClimbedNumber.ListenByCourseId()
    private let fetchUserUsecase = Usecase.User.FetchById()
    private let fetchRockUsecase = Usecase.Rock.FetchById()

    private var bindings = Set<AnyCancellable>()

    init(course: Entity.Course) {
        self.course = course

        self.setupInput()
        self.setupOutput()
    }

    private func setupInput() {
        self.input.finishedCollectionViewSetup
            .asyncSink { [weak self] in

                guard let self = self else { return }

                await self.fetchRegisteredUser()
                await self.fetchParentRock()
            }
            .store(in: &self.bindings)
    }

    private func fetchRegisteredUser() async {
        self.output.fetchRegisteredUserState = .loading
        do {
            self.output.fetchRegisteredUserState = .loading
            let user = try await self.fetchUserUsecase.fetchUser(
                by: self.course.registeredUserId
            )
            self.output.fetchRegisteredUserState = .finish(content: user)
        } catch {
            self.output.fetchRegisteredUserState = .failure(error)
        }
    }

    private func fetchParentRock() async {
        self.output.fetchParentRockState = .loading
        do {
            let rock = try await self.fetchRockUsecase.fetch(
                by: self.course.parentRockId
            )
            self.output.fetchParentRockState = .finish(content: rock)
        } catch {
            self.output.fetchParentRockState = .failure(error)
        }
    }

    private func setupOutput() {
        self.listenTotalClimbedNumberUsecase
            .listen(
                useTestData: false,
                courseId: self.course.id,
                parantPath: self.course.parentPath
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .assign(to: &self.output.$totalClimbedNumber)
    }
}

extension CourseDetailViewModel {
    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var fetchParentRockState: LoadingState<Entity.Rock> = .stanby
        @Published var fetchRegisteredUserState: LoadingState<Entity.User> = .stanby
        @Published var totalClimbedNumber: Entity.TotalClimbedNumber = .init(flash: 0, redPoint: 0)
    }
}
