import Combine
import Foundation
import Resolver
import Domain
import Collections

actor CourseSearchViewModel: ObservableObject {

    @Published nonisolated var courses: OrderedSet<Entity.Course> = []
    @Published nonisolated var viewState: LoadableViewState = .standby

    private var page: Int = 0

    @Injected private var searchCourseListUsecase: SearchCourseUsecaseProtocol

    @MainActor func search(
        condition: SearchCondition,
        isAdditional: Bool
    ) async {
        self.viewState = .loading

        do {
            let courses = try await searchCourseListUsecase.search(text: condition.searchText)

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
        self.page += 1
        await self.search(condition: condition, isAdditional: true)
    }

    func refresh(condition: SearchCondition) async {
        self.page = 0
        await self.search(condition: condition, isAdditional: false)
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