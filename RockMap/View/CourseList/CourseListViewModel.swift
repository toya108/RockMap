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
}

class CourseListViewModel: CourseListViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    private let userReference: DocumentRef?

    private var bindings = Set<AnyCancellable>()

    init(userReference: DocumentRef?) {
        self.userReference = userReference

        fetchCourseList()
    }

    func fetchCourseList() {

        guard
            let userReference = userReference
        else {
            output.isEmpty = true
            return
        }

        FirestoreManager.db
            .collectionGroup(FIDocument.Course.colletionName)
            .whereField("registedUserReference", in: [userReference])
            .getDocuments(FIDocument.Course.self)
            .catch { _ -> Just<[FIDocument.Course]> in
                return .init([])
            }
            .map { Set<FIDocument.Course>($0) }
            .sink { [weak self] courses in

                guard let self = self else { return }

                self.output.isEmpty = courses.isEmpty
                self.output.courses = courses
            }
            .store(in: &bindings)
    }

}

extension CourseListViewModel {

    struct Input {}

    final class Output {
        @Published var courses: Set<FIDocument.Course> = []
        @Published var isEmpty: Bool = false
    }

}
