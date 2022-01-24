import Combine
import Domain
import Resolver

actor HomeViewModel: ObservableObject {
    @Published nonisolated var searchText = ""

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
