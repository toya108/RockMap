import Auth
import Combine
import Foundation

protocol ClimbedUserListViewModelProtocol: ViewModelProtocol {
    var input: ClimbedUserListViewModel.Input { get }
    var output: ClimbedUserListViewModel.Output { get }
}

class ClimbedUserListViewModel: ClimbedUserListViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()

    private let course: Entity.Course
    private var bindings = Set<AnyCancellable>()
    private let fetchClimbedSubject = PassthroughSubject<String, Error>()
    private let fetchClimbRecordUsecase = Usecase.ClimbRecord.FetchByCourseId()
    private let fetchUserUsecase = Usecase.User.FetchById()

    private let deleteClimbRecordUsecase = Usecase.ClimbRecord.Delete()

    init(course: Entity.Course) {
        self.course = course
        self.setupOutput()
        self.fetchClimbed()
    }

    private func fetchClimbed() {
        Task {
            do {
                let records = try await self.fetchClimbRecordUsecase.fetch(by: self.course.id)
                self.output.climbRecordList = records
            } catch {
                print(error)
            }
        }
    }

    private func setupOutput() {
        let share = self.output.$climbRecordList
            .filter { !$0.isEmpty }
            .share()

        share
            .asyncSink(receiveValue: updateMyClimbRecordCellData)
            .store(in: &self.bindings)

        share
            .map { $0.filter { $0.registeredUserId != AuthManager.shared.uid } }
            .map { Set($0) }
            .map { $0.map(\.registeredUserId) }
            .asyncSink(receiveValue: updateClimbRecordCellData)
            .store(in: &self.bindings)
    }

    private var updateMyClimbRecordCellData: ([Entity.ClimbRecord]) async -> Void {{ [weak self] _ in

        guard let self = self else { return }

        do {
            let user = try await self.fetchUserUsecase.fetchUser(
                by: AuthManager.shared.uid
            )
            self.output.myClimbedCellData = self.output.climbRecordList
                .filter { $0.registeredUserId == AuthManager.shared.uid }
                .map {
                    ClimbedCellData(
                        climbed: $0,
                        user: user,
                        isOwned: true
                    )
                }
        } catch {

        }
    }}

    private var updateClimbRecordCellData: ([String]) async -> Void {{ [weak self] userIds in

        guard let self = self else { return }

        do {

            var users: [Entity.User] = []

            try await withThrowingTaskGroup(of: Entity.User.self) { group in

                for id in userIds {
                    group.addTask {
                        return try await self.fetchUserUsecase.fetchUser(by: id)
                    }
                }

                for try await user in group {
                    users.append(user)
                }
            }

            let cellData = self.output.climbRecordList.compactMap { climbed -> ClimbedCellData? in

                guard
                    let user = users.first(
                        where: { climbed.registeredUserId == $0.id }
                    )
                else {
                    return nil
                }

                return .init(
                    climbed: climbed,
                    user: user,
                    isOwned: false
                )
            }

            self.output.climbedCellData = cellData
        } catch {

        }
    }}

    func deleteClimbRecord(climbRecord: Entity.ClimbRecord) async throws {
        try await self.deleteClimbRecordUsecase.delete(
            parentPath: climbRecord.parentPath,
            id: climbRecord.id
        )
    }

    func updateClimbedData(
        id: String,
        date: Date,
        type: Entity.ClimbRecord.ClimbedRecordType
    ) {
        guard
            let index = output.myClimbedCellData.firstIndex(where: { $0.climbed.id == id })
        else {
            return
        }

        self.output.myClimbedCellData[index].climbed.climbedDate = date
        self.output.myClimbedCellData[index].climbed.type = type

        self.output.myClimbedCellData.sort(
            by: { $0.climbed.climbedDate < $1.climbed.climbedDate }
        )
    }
}

extension ClimbedUserListViewModel {
    struct ClimbedCellData: Hashable {
        var climbed: Entity.ClimbRecord
        let user: Entity.User
        let isOwned: Bool
    }
}

extension ClimbedUserListViewModel {
    struct Input {}

    final class Output {
        @Published var climbRecordList: [Entity.ClimbRecord] = []
        @Published var myClimbedCellData: [ClimbedCellData] = []
        @Published var climbedCellData: [ClimbedCellData] = []
    }
}
