import Combine
import CoreLocation

class RockSearchViewModel: ViewModelProtocol {
    @Published private(set) var rockDocuments: [Entity.Rock] = []
    @Published private(set) var error: Error?
    @Published var location: CLLocation?
    @Published var address: String?
    @Published var locationSelectState: LocationSelectButtonState = .standby

    private let fetchRocksUsecase = Usecase.Rock.FetchAll()

    private var bindings = Set<AnyCancellable>()

    init() {
        self.setupBindings()
        self.fetchRockList()
    }

    private func setupBindings() {
        $location
            .compactMap { $0 }
            .flatMap { LocationManager.shared.reverseGeocoding(location: $0) }
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map(\.address)
            .map { Optional($0) }
            .assign(to: &$address)
    }

    func fetchRockList() {
        self.fetchRocksUsecase.fetchAll()
            .catch { error -> Just<[Entity.Rock]> in
                self.error = error
                return .init([])
            }
            .assign(to: &self.$rockDocuments)
    }
}
