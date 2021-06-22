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

    @Published var climbedDate: Date?
    @Published var climbRecordType: FIDocument.ClimbRecord.ClimbedRecordType = .flash
    @Published private(set) var loadingState: LoadingState<Void> = .stanby

    private var bindings = Set<AnyCancellable>()

    init(registerType: RegisterType) {
        self.registerType = registerType
    }

    func editClimbed() {

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

            let recordType = FIDocument.ClimbRecord.ClimbedRecordType.self

            switch climbRecordType {
                case .flash:
                    badge.updateData(
                        [
                            recordType.flash.fieldName: FirestoreManager.Value.increment(1.0),
                            recordType.redPoint.fieldName: FirestoreManager.Value.increment(-1.0)
                        ],
                        forDocument: climbed.totalNumberReference
                    )

                case .redPoint:
                    badge.updateData(
                        [
                            recordType.redPoint.fieldName: FirestoreManager.Value.increment(1.0),
                            recordType.flash.fieldName: FirestoreManager.Value.increment(-1.0)
                        ],
                        forDocument: climbed.totalNumberReference
                    )

            }
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

    func registerClimbed() {

        guard
            let climbedDate = climbedDate,
            case let .create(course) = registerType
        else {
            return
        }

        loadingState = .loading

        course.makeDocumentReference()
            .collection(FIDocument.TotalClimbedNumber.colletionName)
            .getDocuments(FIDocument.TotalClimbedNumber.self)
            .catch { _ -> Just<[FIDocument.TotalClimbedNumber]> in
                return .init([])
            }
            .compactMap { $0.first }
            .flatMap { [weak self] totalNumber -> AnyPublisher<Void, Error> in

                guard let self = self else {
                    return .init(Result<Void, Error>.Publisher(.failure(FirestoreError.nilResultError)))
                }

                let badge = FirestoreManager.db.batch()

                let climbed = FIDocument.ClimbRecord(
                    registeredUserId: AuthManager.shared.uid,
                    parentCourseId: course.id,
                    parentCourseReference: course.makeDocumentReference(),
                    totalNumberReference: totalNumber.makeDocumentReference(),
                    parentPath: AuthManager.shared.authUserReference?.path ?? "",
                    climbedDate: climbedDate,
                    type: self.climbRecordType
                )
                badge.setData(climbed.dictionary, forDocument: climbed.makeDocumentReference())

                badge.updateData(
                    [self.climbRecordType.fieldName: FirestoreManager.Value.increment(1.0)],
                    forDocument: totalNumber.makeDocumentReference()
                )

                return badge.commit()
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
