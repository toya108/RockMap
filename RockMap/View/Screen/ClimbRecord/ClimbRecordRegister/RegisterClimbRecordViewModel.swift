//
//  RegisterClimbedViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/11.
//

import Combine
import Foundation

class RegisterClimbRecordViewModel {

    enum RegisterType {
        case edit(FIDocument.ClimbRecord)
        case create(FIDocument.Course)
    }

    let registerType: RegisterType
    private let setClimbRecordUsecase = Usecase.ClimbRecord.Set()

    @Published var climbedDate: Date?
    @Published var climbRecordType: FIDocument.ClimbRecord.ClimbedRecordType = .flash
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

        loadingState = .loading

        let badge = FirestoreManager.db.batch()

        if climbed.climbedDate != climbedDate {
            badge.updateData(
                ["climbedDate": climbedDate],
                forDocument: climbed.makeDocumentReference()
            )
        }

        if climbed.type != climbRecordType {
            badge.updateData(
                ["type": climbRecordType.rawValue],
                forDocument: climbed.makeDocumentReference()
            )
        }
        badge.commit()
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.loadingState = .finish(content: ())

                        case .failure(let error):
                            self.loadingState = .failure(error)

                    }
                },
                receiveValue: {}
            )
            .store(in: &bindings)
    }

    func registerClimbRecord() {

        guard
            let climbedDate = climbedDate,
            case let .create(course) = registerType
        else {
            return
        }

        loadingState = .loading
//
//        let climbRecord = Entity.ClimbRecord(
//            id: UUID().uuidString,
//            registeredUserId: AuthManager.shared.uid,
//            parentCourseId: course.id,
//            parentCourseReference: course.makeDocumentReference().path,
//            createdAt: Date(),
//            updatedAt: nil,
//            parentPath: AuthManager.shared.authUserReference?.path ?? "",
//            climbedDate: climbedDate,
//            type: .flash
//        )

        course.makeDocumentReference()
            .collection(FIDocument.TotalClimbedNumber.colletionName)
            .getDocuments(FIDocument.TotalClimbedNumber.self)
            .catch { error -> Just<[FIDocument.TotalClimbedNumber]> in
                print(error)
                return .init([])
            }
            .compactMap { $0.first }
            .flatMap { [weak self] totalNumber -> AnyPublisher<Void, Error> in

                guard
                    let self = self
                else {
                    return .init(Result<Void, Error>.Publisher(.failure(FirestoreError.nilResultError)))
                }

                let climbRecord = FIDocument.ClimbRecord(
                    registeredUserId: AuthManager.shared.uid,
                    parentCourseId: course.id,
                    parentCourseReference: course.makeDocumentReference(),
                    totalNumberReference: totalNumber.makeDocumentReference(),
                    parentPath: AuthManager.shared.authUserReference?.path ?? "",
                    climbedDate: climbedDate,
                    type: self.climbRecordType
                )

                return climbRecord.makeDocumentReference().setData(from: climbRecord)
            }
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.loadingState = .finish(content: ())

                        case .failure(let error):
                            self.loadingState = .failure(error)

                    }
                },
                receiveValue: {}
            )
            .store(in: &bindings)
    }

}
