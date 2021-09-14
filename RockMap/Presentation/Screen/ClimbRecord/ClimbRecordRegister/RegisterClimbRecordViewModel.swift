import Auth
import Combine
import Foundation

class RegisterClimbRecordViewModel {
    enum RegisterType {
        case edit(Entity.ClimbRecord)
        case create(Entity.Course)
    }

    let registerType: RegisterType
    private let setClimbRecordUsecase = Usecase.ClimbRecord.Set()
    private let updateClimbRecordUsecase = Usecase.ClimbRecord.Update()

    @Published var climbedDate: Date?
    @Published var climbRecordType: Entity.ClimbRecord.ClimbedRecordType = .flash
    @Published private(set) var loadingState: LoadingState<Void> = .stanby

    private var bindings = Set<AnyCancellable>()

    init(registerType: RegisterType) {
        self.registerType = registerType
    }

    func isSelectedFutureDate(climbedDate: Date?) -> Bool {
        guard
            let climbedDate = climbedDate
        else {
            return true
        }

        let result = climbedDate.compare(Date())
        switch result {
        case .orderedAscending, .orderedSame:
            return false

        case .orderedDescending:
            return true
        }
    }

    func editClimbRecord() {
        guard
            let climbedDate = climbedDate,
            case let .edit(climbed) = registerType
        else {
            return
        }

        self.loadingState = .loading

        let targetClimbedDate: Date? = climbed.climbedDate == climbedDate ? nil : climbedDate
        let targetClimbedRecordType: Entity.ClimbRecord.ClimbedRecordType?
            = climbed.type == self.climbRecordType ? nil : self.climbRecordType

        self.updateClimbRecordUsecase.update(
            parentPath: climbed.parentPath,
            id: climbed.id,
            climbedDate: targetClimbedDate,
            type: targetClimbedRecordType
        )
        .catch { [weak self] error -> Empty in

            guard let self = self else { return Empty() }

            self.loadingState = .failure(error)
            print(error)
            return Empty()
        }
        .sink { [weak self] in

            guard let self = self else { return }

            self.loadingState = .finish(content: ())
        }
        .store(in: &self.bindings)
    }

    func registerClimbRecord() {
        guard
            let climbedDate = climbedDate,
            case let .create(course) = registerType
        else {
            return
        }

        self.loadingState = .loading

        let climbRecord = Entity.ClimbRecord(
            id: UUID().uuidString,
            registeredUserId: AuthManager.shared.uid,
            parentCourseId: course.id,
            parentCourseReference: course.parentPath + "courses" + course.id,
            createdAt: Date(),
            updatedAt: nil,
            parentPath: AuthManager.shared.userPath,
            climbedDate: climbedDate,
            type: .flash
        )

        self.setClimbRecordUsecase.set(climbRecord: climbRecord)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.loadingState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.loadingState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }
}
