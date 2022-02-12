import Combine
import Foundation
import Utilities

class ClimbedCourseListViewModel: ObservableObject {

    struct ClimbedCourse: Identifiable {
        var id: String { self.course.id }
        let course: Entity.Course
        let record: Entity.ClimbRecord
    }

    @Published var climbCourses: [ClimbedCourse] = []
    @Published var viewState: LoadableViewState = .standby

    private let fetchClimbRecordUsecase = Usecase.ClimbRecord.FetchByUserId()
    private let fetchCourseUsecase = Usecase.Course.FetchById()
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    @MainActor func load() {
        Task {
            self.viewState = .loading

            do {
                let records = try await fetchClimbRecords()
                self.climbCourses = try await fetchClimbedCourses(records: records)
                self.viewState = .finish
            } catch {
                print(error)
                self.viewState = .failure(error)
            }
        }
    }

    private func fetchClimbRecords() async throws -> [Entity.ClimbRecord] {
        let records = try await self.fetchClimbRecordUsecase.fetch(by: userId)
        return records.sorted { $0.createdAt > $1.createdAt }
    }

    private func fetchClimbedCourses(
        records: [Entity.ClimbRecord]
    ) async throws -> [ClimbedCourse] {
        var courses: [ClimbedCourse] = []

        await withTaskGroup(of: ClimbedCourse.self) { group in

            for record in records {
                guard
                    let course = try? await self.fetchCourseUsecase.fetch(
                        by: record.parentCourseId
                    )
                else {
                    continue
                }

                group.addTask {
                    .init(
                        course: course,
                        record: record
                    )
                }
            }

            for await course in group {
                courses.append(course)
            }
        }

        return courses
    }
}
