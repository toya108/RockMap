import Combine
import Resolver
import Domain
import Collections

actor CourseListViewModel: ObservableObject {

    @Published nonisolated var courses: OrderedSet<Entity.Course> = []
    @Published nonisolated var viewState: LoadableViewState = .stanby

    private var page: Int = 0
    
    @Injected private var fetchCouseListUsecase: FetchCourseListUsecaseProtocol

    @MainActor func load() async {
        self.viewState = .loading

        do {
            let courses = try await fetchCouseListUsecase.fetch(page: page)
            self.courses.append(contentsOf: courses)
            self.viewState = .finish
        } catch {
            self.viewState = .failure(error)
        }
    }

    func additionalLoad() async {
        self.page += 1
        await self.load()
    }

    func refresh() async {
        self.page = 0
        await self.load()
    }

    func shouldAdditionalLoad(course: Entity.Course) async -> Bool {
        guard let index = courses.firstIndex(of: course) else {
            return false
        }
        return course.id == courses.last?.id
        && (index / 20) == 0
        && index != 0
    }
}
