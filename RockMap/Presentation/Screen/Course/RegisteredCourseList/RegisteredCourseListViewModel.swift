import Combine
import Resolver
import Foundation

class RegisteredCourseListViewModel: ObservableObject {

    @Published var viewState: LoadableViewState = .standby

    @Published var courses: [Entity.Course] = []
    @Published var isPresentedCourseRegister = false
    @Published var isPresentedDeleteCourseAlert = false
    @Published var isPresentedDeleteFailureAlert = false
    var editingCourse: Entity.Course?

    @Injected private var fetchCoursesUseCase: FetchCourseUsecaseProtocol
    @Injected private var deleteCourseUsecase: DeleteCourseUsecaseProtocol
    @Injected private var authAccessor: AuthAccessorProtocol

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    var isEditable: Bool {
        userId == authAccessor.uid
    }

    @MainActor func delete() {

        guard let course = editingCourse else {
            return
        }

        self.viewState = .loading

        Task {
            do {
                try await self.deleteCourseUsecase.delete(id: course.id)

                guard
                    let index = self.courses.firstIndex(of: course)
                else {
                    return
                }
                self.courses.remove(at: index)
                self.viewState = .finish
            } catch {
                self.viewState = .failure(error)
                self.isPresentedDeleteFailureAlert = true
            }
        }
    }

    @MainActor func fetchCourses() {
        self.viewState = .loading

        Task {
            do {
                let courses = try await self.fetchCoursesUseCase.fetch(by: self.userId)
                self.courses = courses.sorted { $0.createdAt > $1.createdAt }
                self.viewState = .finish
            } catch {
                self.viewState = .failure(error)
            }
        }
    }
}
