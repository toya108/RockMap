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

    private let deleteClimbRecordUsecase = Usecase.ClimbRecord.Delete()

    init(course: Entity.Course) {
        self.course = course
        self.setupOutput()
        self.fetchClimbed()
    }

    private func fetchClimbed() {
        self.fetchClimbRecordUsecase.fetch(by: self.course.id)
            .catch { _ in Empty() }
            .assign(to: &self.output.$climbRecordList)
    }

    private func setupOutput() {
        let share = self.output.$climbRecordList
            .filter { !$0.isEmpty }
            .share()

        share
            .flatMap { _ in
                Usecase.User.FetchById().fetchUser(by: AuthManager.shared.uid)
            }
            .catch { _ in Empty() }
            .compactMap { $0 }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.output.myClimbedCellData = self.output.climbRecordList
                    .filter { $0.registeredUserId == AuthManager.shared.uid }
                    .map {
                        ClimbedCellData(
                            climbed: $0,
                            user: user,
                            isOwned: true
                        )
                    }
            }
            .store(in: &self.bindings)

        share
            .map { $0.filter { $0.registeredUserId != AuthManager.shared.uid } }
            .map { Set($0) }
            .map { $0.map(\.registeredUserId) }
            .flatMap {
                $0.publisher.flatMap { id in
                    Usecase.User.FetchById().fetchUser(by: id)
                }
                .collect()
            }
            .catch { _ in Empty() }
            .sink { [weak self] climbedUserList in

                guard let self = self else { return }

                let cellData = self.output.climbRecordList
                    .compactMap { climbed -> ClimbedCellData? in

                        guard
                            let user = climbedUserList
                                .first(where: { climbed.registeredUserId == $0.id })
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
            }
            .store(in: &self.bindings)
    }

    func deleteClimbRecord(
        climbRecord: Entity.ClimbRecord,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.deleteClimbRecordUsecase
            .delete(parentPath: climbRecord.parentPath, id: climbRecord.id)
            .catch { error -> Empty in
                completion(.failure(error))
                return Empty()
            }
            .sink {
                completion(.success(()))
            }
            .store(in: &self.bindings)
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
