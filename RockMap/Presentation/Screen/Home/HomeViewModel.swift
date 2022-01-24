import Combine
import Domain
import Resolver

actor HomeViewModel: ObservableObject {
    @Published nonisolated var searchText = ""
    @Published nonisolated var selectedCategory: CategoryKind = .rock

    @Injected private var searchRockUseCase: SearchRockUsecaseProtocol

    private var cancellables = Set<AnyCancellable>()

    func setupBindings() {
        $searchText
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .asyncSink { [weak self] _ in

                guard let self = self else { return }

                await self.searchRock()
            }
            .store(in: &cancellables)
    }

    @MainActor func resetSearchText() {
        searchText = ""
    }

    func searchRock() async {
        let a = try? await searchRockUseCase.search(text: searchText)
        print(a)
    }
}

enum CategoryKind: String, CaseIterable, Identifiable {
    case rock
    case course
    case user

    var id: String { self.rawValue }

    var name: String {
        switch self {
            case .rock:
                return "rock"
            case .course:
                return "course"
            case .user:
                return "user"
        }
    }
}
