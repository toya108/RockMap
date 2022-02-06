import Combine
import Foundation
import Resolver
import Domain
import Collections

actor CourseListViewModel: ObservableObject {

    @Published nonisolated var courses: OrderedSet<Entity.Course> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    @Injected private var fetchCouseListUsecase: FetchCourseListUsecaseProtocol

    @MainActor func load(isAdditional: Bool = false) async {
        self.viewState = .loading

        do {
            let courses = try await fetchCouseListUsecase.fetch(
                startAt: isAdditional ? startAt : Date()
            )

            if !isAdditional {
                self.courses.removeAll()
            }
            self.courses.append(contentsOf: courses)

            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad() async {
        await self.load(isAdditional: true)
    }

    func shouldAdditionalLoad(course: Entity.Course) async -> Bool {
        guard let index = courses.firstIndex(of: course) else {
            return false
        }
        return course.id == courses.last?.id
        && (Double(index) / 20.0) == 0.0
        && index != 0
    }

    private var startAt: Date {
        if let last = courses.last {
            return last.createdAt
        } else {
            return Date()
        }
    }
}
