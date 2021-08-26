//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine
import Foundation

protocol CourseDetailViewModelProtocol: ViewModelProtocol {
    var input: CourseDetailViewModel.Input { get }
    var output: CourseDetailViewModel.Output { get }
}

final class CourseDetailViewModel: CourseDetailViewModelProtocol {
    var input: Input = .init()
    var output: Output = .init()
    
    let course: Entity.Course
    private let listenTotalClimbedNumberUsecase = Usecase.TotalClimbedNumber.ListenByCourseId()
    private let fetchRegisteredUserSubject = PassthroughSubject<String, Error>()
    private let fetchParentRockSubject = PassthroughSubject<String, Error>()
    private let fetchUserUsecase = Usecase.User.FetchById()

    private var bindings = Set<AnyCancellable>()
    
    init(course: Entity.Course) {
        self.course = course

        setupInput()
        setupOutput()
    }

    private func setupInput() {
        input.finishedCollectionViewSetup
            .sink { [weak self] in

                guard let self = self else { return }

                self.fetchRegisteredUserSubject.send(self.course.registeredUserId)
                self.fetchParentRockSubject.send(self.course.parentRockId)
            }
            .store(in: &bindings)
    }
    
    private func setupOutput() {
        fetchRegisteredUserSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchRegisteredUserState = .loading
            })
            .flatMap { userId -> AnyPublisher<Entity.User, Error> in
                Usecase.User.FetchById().fetchUser(by: userId)
            }
            .sinkState { [weak self] state in
                self?.output.fetchRegisteredUserState = state
            }
            .store(in: &bindings)

        fetchParentRockSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchParentRockState = .loading
            })
            .map {
                FirestoreManager.db
                    .collectionGroup(FIDocument.Rock.colletionName)
                    .whereField("id", in: [$0])
            }
            .flatMap {
                $0.getDocuments(FIDocument.Rock.self)
            }
            .compactMap { $0.first }
            .breakpointOnError()
            .sinkState { [weak self] state in
                self?.output.fetchParentRockState = state
            }
            .store(in: &bindings)

        listenTotalClimbedNumberUsecase
            .listen(useTestData: false, courseId: course.id, parantPath: course.parentPath)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .assign(to: &output.$totalClimbedNumber)
    }
}

extension CourseDetailViewModel {
    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<(Void), Never>()
    }

    final class Output {
        @Published var fetchParentRockState: LoadingState<FIDocument.Rock> = .stanby
        @Published var fetchRegisteredUserState: LoadingState<Entity.User> = .stanby
        @Published var totalClimbedNumber: Entity.TotalClimbedNumber = .init(flash: 0, redPoint: 0)
    }
}
