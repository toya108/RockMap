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
    @Published private(set) var loadingState: LoadingState<Void> = .standby

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

        Task {
            do {
                try await self.updateClimbRecordUsecase.update(
                    id: climbed.id,
                    climbedDate: targetClimbedDate,
                    type: targetClimbedRecordType
                )

                self.loadingState = .finish(content: ())
            } catch {
                self.loadingState = .failure(error)
            }
        }
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
            parentCourseReference: ["courses", course.id].joined(separator: "/"),
            createdAt: Date(),
            updatedAt: nil,
            climbedDate: climbedDate,
            type: climbRecordType
        )
        Task {
            do {
                try await self.setClimbRecordUsecase.set(climbRecord: climbRecord)
                self.loadingState = .finish(content: ())
            } catch {
                self.loadingState = .failure(error)
            }
        }
    }
}
