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

    @Published private var climbRecordList: [FIDocument.ClimbRecord] = []
    private var bindings = Set<AnyCancellable>()

    init() {
        bindOutput()
        fetchClimbedList()
    }

    private func bindOutput() {
        let share = $climbRecordList.share()

        share
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)

        share
            .filter { !$0.isEmpty }
            .sink { [weak self] climbRecordList in

                guard let self = self else { return }

                climbRecordList
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
            .collectionGroup(FIDocument.ClimbRecord.colletionName)
            .whereField("registeredUserId", in: [AuthManager.shared.uid])
            .getDocuments(FIDocument.ClimbRecord.self)
            .catch { _ in Empty() }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$climbRecordList)
    }

}

extension MyClimbedListViewModel {

    struct ClimbedCourse: Hashable {
        let course: FIDocument.Course
        let climbed: FIDocument.ClimbRecord
    }

    struct Input {}

    final class Output {
        @Published var climbedCourses: [ClimbedCourse] = []
        @Published var isEmpty: Bool = false
    }

}
