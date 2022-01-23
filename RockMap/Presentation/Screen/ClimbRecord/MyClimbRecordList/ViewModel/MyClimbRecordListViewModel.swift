import Auth
import Combine
import Foundation
import Utilities

protocol MyClimbedListViewModelProtocol: ViewModelProtocol {
    var input: MyClimbedListViewModel.Input { get }
    var output: MyClimbedListViewModel.Output { get }
}

class MyClimbedListViewModel: MyClimbedListViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()

    @Published private var climbRecordList: [Entity.ClimbRecord] = []
    private var bindings = Set<AnyCancellable>()
    private let fetchClimbRecordUsecase = Usecase.ClimbRecord.FetchByUserId()
    private let fetchCourseUsecase = Usecase.Course.FetchById()

    init() {
        self.bindOutput()
        self.fetchClimbedList()
    }

    private func bindOutput() {
        let share = $climbRecordList.share()

        share.map(\.isEmpty).assign(to: &self.output.$isEmpty)

        share
            .filter { !$0.isEmpty }
            .asyncMap(
                transform: { [weak self] climbRecordList in

                    guard let self = self else { throw MemoryError.noneSelf }

                    return try await self.fetchClimbedCourses(climbRecordList: climbRecordList)
                },
                errorCompletion: {
                    print($0)
                }
            )
            .assign(to: &self.output.$climbedCourses)
    }

    private func fetchClimbedCourses(
        climbRecordList: [Entity.ClimbRecord]
    ) async throws -> [ClimbedCourse] {
        var courses: [ClimbedCourse] = []

        try await withThrowingTaskGroup(of: ClimbedCourse.self) { group in

            for climbRecord in climbRecordList {
                group.addTask {
                    .init(
                        course: try await self.fetchCourseUsecase.fetch(
                            by: climbRecord.parentCourseId
                        ),
                        climbed: climbRecord
                    )
                }
            }

            for try await course in group {
                courses.append(course)
            }
        }

        return courses
    }

    func fetchClimbedList() {
        Task {
            do {
                let records = try await self.fetchClimbRecordUsecase.fetch(by: AuthManager.shared.uid)
                self.climbRecordList = records.sorted { $0.createdAt > $1.createdAt }
            } catch {
                print(error)
            }
        }
    }
}

extension MyClimbedListViewModel {
    struct ClimbedCourse: Hashable {
        let course: Entity.Course
        let climbed: Entity.ClimbRecord
    }

    struct Input {}

    final class Output {
        @Published var climbedCourses: [ClimbedCourse] = []
        @Published var isEmpty: Bool = false
    }
}
