import Auth
import Combine

protocol CourseListViewModelProtocol: ViewModelProtocol {
    var input: CourseListViewModel.Input { get }
    var output: CourseListViewModel.Output { get }

    func fetchCourseList()
}

class CourseListViewModel: CourseListViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()
    let isMine: Bool

    private let userId: String
    private let fetchCoursesUsecase = Usecase.Course.FetchByUserId()
    private let deleteCourseUsecase = Usecase.Course.Delete()
    private var deleteCourse: Entity.Course?

    private var bindings = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId
        self.isMine = userId == AuthManager.shared.uid

        self.bindInput()
        self.bindOutput()
        self.fetchCourseList()
    }

    private func bindInput() {
        self.input.deleteCourseSubject
            .handleEvents(receiveOutput: { [weak self] course in

                guard let self = self else { return }

                self.output.deleteState = .loading
                self.deleteCourse = course
            })
            .asyncSink { [weak self] course in

                guard let self = self else { return }

                do {
                    try await self.deleteCourseUsecase.delete(
                        id: course.id,
                        parentPath: course.parentPath
                    )

                    guard
                        let deleteCourse = self.deleteCourse,
                        let index = self.output.courses.firstIndex(of: deleteCourse)
                    else {
                        return
                    }
                    self.output.courses.remove(at: index)
                    self.output.deleteState = .finish(content: ())

                } catch {
                    self.output.deleteState = .failure(error)
                }
            }
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$courses
            .map(\.isEmpty)
            .assign(to: &self.output.$isEmpty)
    }

    func fetchCourseList() {
        Task {
            do {
                let courses = try await self.fetchCoursesUsecase.fetch(by: self.userId)
                self.output.courses = courses.sorted { $0.createdAt > $1.createdAt }
            } catch {
                print(error)
            }
        }
    }
}

extension CourseListViewModel {
    struct Input {
        let deleteCourseSubject = PassthroughSubject<Entity.Course, Never>()
    }

    final class Output {
        @Published var courses: [Entity.Course] = []
        @Published var isEmpty: Bool = false
        @Published var deleteState: LoadingState<Void> = .stanby
    }
}
