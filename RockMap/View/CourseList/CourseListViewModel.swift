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

    var input: Input
    var output: Output = .init()

    private let userReference: DocumentRef?

    private var bindings = Set<AnyCancellable>()

    init(userReference: DocumentRef?) {
        self.userReference = userReference

        let deleteCourse = PassthroughSubject<FIDocument.Course, Never>()
        self.input = Input(
            deleteCourse: deleteCourse.send
        )

        setupDeleteCourseSubject(deleteCourse)

        output.$courses
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)

        fetchCourseList()
    }

    private func setupDeleteCourseSubject(_ subject: PassthroughSubject<FIDocument.Course, Never>) {
        subject
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

    func fetchCourseList() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Course.colletionName)
            .whereField("registedUserId", in: [AuthManager.shared.uid])
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
        let deleteCourse: (FIDocument.Course) -> Void
    }

    final class Output {
        @Published var courses: [FIDocument.Course] = []
        @Published var isEmpty: Bool = false
        @Published var deleteState: LoadingState = .stanby
    }

}
