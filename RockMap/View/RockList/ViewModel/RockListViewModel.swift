//
//  RockListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import Combine

protocol RockListViewModelProtocol: ViewModelProtocol {
    var input: RockListViewModel.Input { get }
    var output: RockListViewModel.Output { get }

    func fetchRockList()
}

class RockListViewModel: RockListViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    private let userReference: DocumentRef?

    private var bindings = Set<AnyCancellable>()

    init(userReference: DocumentRef?) {
        self.userReference = userReference

        bindInput()
        bindOutput()
        fetchRockList()
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
                        let index = self.output.rocks.firstIndex(of: course)
                    else {
                        return
                    }
                    self.output.rocks.remove(at: index)
                }
            )
            .store(in: &bindings)
    }

    private func bindOutput() {
        output.$rocks
            .map(\.isEmpty)
            .assign(to: &output.$isEmpty)
    }

    func fetchRockList() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Rock.colletionName)
            .whereField("registedUserId", in: [AuthManager.shared.uid])
            .getDocuments(FIDocument.Rock.self)
            .catch { _ -> Just<[FIDocument.Rock]> in
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &output.$rocks)
    }

}

extension RockListViewModel {

    struct Input {
        let deleteCourseSubject = PassthroughSubject<FIDocument.Rock, Never>()
    }

    final class Output {
        @Published var rocks: [FIDocument.Rock] = []
        @Published var isEmpty: Bool = false
        @Published var deleteState: LoadingState = .stanby
    }

}
