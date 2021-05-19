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
    
    let course: FIDocument.Course
    let fetchRegisteredUserSubject = PassthroughSubject<String, Error>()

    private var bindings = Set<AnyCancellable>()
    
    init(course: FIDocument.Course) {
        self.course = course

        setupInput()
        setupOutput()
    }

    private func setupInput() {
        input.finishedCollectionViewSetup
            .sink { [weak self] in

                guard let self = self else { return }

                self.fetchRegisteredUserSubject.send(self.course.registedUserId)
            }
            .store(in: &bindings)
    }
    
    private func setupOutput() {
        fetchRegisteredUserSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchRegisteredUserState = .loading
            })
            .map {
                FirestoreManager.db
                    .collection(FIDocument.User.colletionName)
                    .document($0)
            }
            .flatMap { $0.getDocument(FIDocument.User.self) }
            .sinkState { [weak self] state in
                self?.output.fetchRegisteredUserState = state
            }
            .store(in: &bindings)

        course.makeDocumentReference()
            .collection(FIDocument.TotalClimbedNumber.colletionName)
            .publisher(as: FIDocument.TotalClimbedNumber.self)
            .catch { _ -> Just<[FIDocument.TotalClimbedNumber]> in
                return .init([])
            }
            .compactMap { $0.first }
            .assign(to: &output.$totalClimbedNumber)
    }
}

extension CourseDetailViewModel {
    struct Input {
        let finishedCollectionViewSetup = PassthroughSubject<(Void), Never>()
    }

    final class Output {
        @Published var fetchRegisteredUserState: LoadingState<FIDocument.User> = .stanby
        @Published var totalClimbedNumber: FIDocument.TotalClimbedNumber?
    }
}
