//
//  MyClimbedListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/27.
//

import Foundation
import Combine

protocol MyClimbedListViewModelProtocol: ViewModelProtocol {
    var input: MyClimbedListViewModel.Input { get }
    var output: MyClimbedListViewModel.Output { get }
}

class MyClimbedListViewModel: MyClimbedListViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    @Published private var climbedList: [FIDocument.Climbed] = []
    private var bindings = Set<AnyCancellable>()

    init() {
        bindOutput()
        fetchClimbedList()
    }

    private func bindOutput() {
        let share = $climbedList.share()

        share
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)

        share
            .filter { !$0.isEmpty }
            .sink { [weak self] climbedList in

                guard let self = self else { return }

                climbedList
                    .forEach { climbed in
                        climbed
                            .parentCourseReference
                            .getDocument(FIDocument.Course.self)
                            .catch { _ -> Just<FIDocument.Course?> in
                                return .init(nil)
                            }
                            .sink { [weak self] course in

                                guard let course = course else { return }

                                let climbedCourse = ClimbedCourse(course: course, climbed: climbed)

                                self?.output.climbedCourses.append(climbedCourse)
                            }
                            .store(in: &self.bindings)
                    }
            }
            .store(in: &bindings)

    }

    func fetchClimbedList() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Climbed.colletionName)
            .whereField("registeredUserId", in: [AuthManager.shared.uid])
            .getDocuments(FIDocument.Climbed.self)
            .catch { _ in Empty() }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$climbedList)
    }

}

extension MyClimbedListViewModel {

    struct ClimbedCourse: Hashable {
        let course: FIDocument.Course
        let climbed: FIDocument.Climbed
    }

    struct Input {}

    final class Output {
        @Published var climbedCourses: [ClimbedCourse] = []
        @Published var isEmpty: Bool = false
    }

}
