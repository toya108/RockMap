import Combine
import Foundation

protocol CourseDetailViewModelProtocol: ViewModelProtocol {
    var input: CourseDetailViewModel.Input { get }
    var output: CourseDetailViewModel.Output { get }
}

final class CourseDetailViewModel: CourseDetailViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()

    let course: Entity.Course
    private let listenTotalClimbedNumberUsecase = Usecase.TotalClimbedNumber.ListenByCourseId()
    private let fetchRegisteredUserSubject = PassthroughSubject<String, Error>()
    private let fetchParentRockSubject = PassthroughSubject<String, Error>()
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
            .sink { [weak self] in

                guard let self = self else { return }

                self.fetchRegisteredUserSubject.send(self.course.registeredUserId)
                self.fetchParentRockSubject.send(self.course.parentRockId)
            }
            .store(in: &self.bindings)
    }

    private func setupOutput() {
        self.fetchRegisteredUserSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchRegisteredUserState = .loading
            })
            .flatMap { userId -> AnyPublisher<Entity.User, Error> in
                Usecase.User.FetchById().fetchUser(by: userId)
            }
            .sinkState { [weak self] state in
                self?.output.fetchRegisteredUserState = state
            }
            .store(in: &self.bindings)

        self.fetchParentRockSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchParentRockState = .loading
            })
            .flatMap {
                self.fetchRockUsecase.fetch(by: $0)
            }
            .sinkState { [weak self] state in
                self?.output.fetchParentRockState = state
            }
            .store(in: &self.bindings)

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
