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
    let fetchHeaderImageSubject = PassthroughSubject<String, Error>()
    let fetchImagesSubject = PassthroughSubject<String, Error>()
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

                self.fetchHeaderImageSubject.send(self.course.id)
                self.fetchImagesSubject.send(self.course.id)
                self.fetchRegisteredUserSubject.send(self.course.registedUserId)
            }
            .store(in: &bindings)
    }
    
    private func setupOutput() {

        fetchHeaderImageSubject
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.output.fetchCourseHeaderState = .loading
            })
            .map {
                StorageManager.makeReference(parent: FINameSpace.Course.self, child: $0)
            }
            .flatMap { StorageManager.getHeaderReference($0) }
            .sinkState { [weak self] state in
                self?.output.fetchCourseHeaderState = state
            }
            .store(in: &bindings)

        fetchImagesSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.fetchCourseImageState = .loading
            })
            .map {
                StorageManager.makeReference(parent: FINameSpace.Course.self, child: $0)
            }
            .flatMap { StorageManager.getNormalImagePrefixes($0) }
            .catch { _ -> Just<[StorageManager.Reference]> in
                return .init([])
            }
            .flatMap { $0.getReferences() }
            .sinkState { [weak self] state in
                self?.output.fetchCourseImageState = state
            }
            .store(in: &bindings)

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
        @Published var fetchCourseHeaderState: LoadingState<StorageManager.Reference> = .stanby
        @Published var fetchCourseImageState: LoadingState<[StorageManager.Reference]> = .stanby
        @Published var fetchRegisteredUserState: LoadingState<FIDocument.User> = .stanby
        @Published var totalClimbedNumber: FIDocument.TotalClimbedNumber?
    }
}
