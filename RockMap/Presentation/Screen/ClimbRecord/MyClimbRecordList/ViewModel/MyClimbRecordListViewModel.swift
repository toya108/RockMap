
import Auth
import Foundation
import Combine

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
    private let fetchCourseUsecase = Usecase.Course.FetchByReference()

    init() {
        bindOutput()
        fetchClimbedList()
    }

    private func bindOutput() {
        let share = $climbRecordList.share()

        share
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)

        share
            .filter { !$0.isEmpty }
            .sink { [weak self] climbRecordList in

                guard let self = self else { return }

                climbRecordList.forEach { climbRecord in
                    self.fetchCourseUsecase.fetch(by: climbRecord.parentCourseReference)
                        .catch { error -> Empty in
                            print(error)
                            return Empty()
                        }
                        .sink { [weak self] course in

                            let climbedCourse = ClimbedCourse(
                                course: course,
                                climbed: climbRecord
                            )

                            self?.output.climbedCourses.append(climbedCourse)
                        }
                        .store(in: &self.bindings)
                }
            }
            .store(in: &bindings)
    }

    func fetchClimbedList() {
        fetchClimbRecordUsecase.fetch(by: AuthManager.shared.uid)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$climbRecordList)
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
