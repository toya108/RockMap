import Combine
import Resolver
import Auth
import Domain
import Foundation

class RegisteredCourseListViewModel: ObservableObject {

    @Published var courses: [Entity.Course] = []
    @Published var isEmpty = false
    @Published var isPresentedCourseRegister = false
    @Published var isPresentedDeleteCourseAlert = false
    @Published var isPresentedDeleteFailureAlert = false
    @Published var isLoading = false
    var editingCourse: Entity.Course?
    var deleteError: Error?

    @Injected private var fetchCoursesUseCase: FetchCourseUsecaseProtocol
    @Injected private var deleteCourseUsecase: DeleteCourseUsecaseProtocol

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    private func bindOutput() {
        self.$courses
            .map(\.isEmpty)
            .assign(to: &self.$isEmpty)
    }

    @MainActor func delete() {

        guard let course = editingCourse else {
            return
        }

        self.isLoading = true

        Task {
            do {
                try await self.deleteCourseUsecase.delete(id: course.id)

                guard
                    let index = self.courses.firstIndex(of: course)
                else {
                    return
                }
                self.courses.remove(at: index)
                self.isLoading = false
            } catch {
                self.deleteError = error
                self.isLoading = false
                self.isPresentedDeleteFailureAlert = true
            }
        }
    }

    @MainActor func fetchCourses() {
        self.isLoading = true

        Task {
            do {
                let courses = try await self.fetchCoursesUseCase.fetch(by: self.userId)
                self.courses = courses.sorted { $0.createdAt > $1.createdAt }
                self.isLoading = false
            } catch {
                print(error)
            }
        }
    }
}