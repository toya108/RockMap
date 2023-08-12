import Combine
import Foundation
import Resolver
import Collections

@MainActor
class CourseListViewModel: ObservableObject {

    @Published var courses: OrderedSet<Entity.Course> = []
    @Published var viewState: LoadableViewState = .standby

    @Injected private var fetchCourseListUsecase: FetchCourseListUsecaseProtocol

    func load(
        condition: SearchCondition,
        isAdditional: Bool = false
    ) async {
        self.viewState = .loading

        do {
            let courses = try await fetchCourseListUsecase.fetch(
                startAt: isAdditional ? startAt : Date(), grade: condition.grade
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

    func additionalLoad(condition: SearchCondition) async {
        await self.load(condition: condition, isAdditional: true)
    }

    func shouldAdditionalLoad(course: Entity.Course) async -> Bool {
        guard let index = courses.firstIndex(of: course) else {
            return false
        }
        return course.id == courses.last?.id
        && Float(index).truncatingRemainder(dividingBy: 20.0) == 0.0
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
