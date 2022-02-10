import Combine
import Foundation
import Resolver
import Domain
import Collections

actor CourseSearchViewModel: ObservableObject {

    @Published nonisolated var courses: OrderedSet<Entity.Course> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    @Injected private var searchCourseListUsecase: SearchCourseUsecaseProtocol

    @MainActor func search(condition: SearchCondition) async {
        self.viewState = .loading

        do {
            let courses = try await searchCourseListUsecase.search(
                text: condition.searchText,
                grade: condition.grade
            )

            self.courses.removeAll()
            self.courses.append(contentsOf: courses)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }
}
