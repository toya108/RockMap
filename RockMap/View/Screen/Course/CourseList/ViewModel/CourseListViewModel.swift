//
//  CourseListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/23.
//

import Combine

protocol CourseListViewModelProtocol: ViewModelProtocol {
    var input: CourseListViewModel.Input { get }
    var output: CourseListViewModel.Output { get }

    func fetchCourseList()
}

class CourseListViewModel: CourseListViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()
    let isMine: Bool

    private let userId: String

    private var bindings = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId
        self.isMine = userId == AuthManager.shared.uid

        bindInput()
        bindOutput()
        fetchCourseList()
    }

    private func bindInput() {
        input.deleteCourseSubject
            .flatMap {
                $0.makeDocumentReference().delete(document: $0)
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] course in
                    guard
                        let self = self,
                        let index = self.output.courses.firstIndex(of: course)
                    else {
                        return
                    }
                    self.output.courses.remove(at: index)
                }
            )
            .store(in: &bindings)
    }

    private func bindOutput() {
        output.$courses
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)
    }

    func fetchCourseList() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Course.colletionName)
            .whereField("registedUserId", in: [userId])
            .getDocuments(FIDocument.Course.self)
            .catch { _ -> Just<[FIDocument.Course]> in
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &output.$courses)
    }

}

extension CourseListViewModel {

    struct Input {
        let deleteCourseSubject = PassthroughSubject<FIDocument.Course, Never>()
    }

    final class Output {
        @Published var courses: [FIDocument.Course] = []
        @Published var isEmpty: Bool = false
        @Published var deleteState: LoadingState<Void> = .stanby
    }

}
