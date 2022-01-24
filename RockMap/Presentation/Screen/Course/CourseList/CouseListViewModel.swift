import Combine
import Resolver
import Domain

actor CourseListViewModel: ObservableObject {

    @Published nonisolated var courses: [Entity.Course] = []
    @Published var isEmpty = false
    @Published var isLoading = false

    private var page: Int = 0
    
    @Injected private var fetchCouseListUsecase: FetchCourseListUsecaseProtocol

    func load() async {
        do {
            let courses = try await fetchCouseListUsecase.fetch(page: page)
            self.courses.append(contentsOf: courses)
        } catch {

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

    func shouldAdditionalLoal(course: Entity.Course) -> Bool {
        course.id == courses.last?.id
    }
}
