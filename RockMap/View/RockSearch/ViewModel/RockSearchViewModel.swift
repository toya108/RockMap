//
//  RockSearchViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/18.
//

import CoreLocation
import Combine

class RockSearchViewModel: ViewModelProtocol {
    
    @Published private(set) var rockDocuments: [FIDocument.Rock] = []
    @Published private(set) var error: Error?
    @Published var location: CLLocation?
    @Published var address: String?
    @Published var locationSelectState: LocationSelectButtonState = .standby

    private var bindings = Set<AnyCancellable>()

    init() {
        setupBindings()
        fetchRockList()
    }

    private func setupBindings() {
        $location
            .compactMap { $0 }
            .flatMap { LocationManager.shared.reverseGeocoding(location: $0) }
            .catch { _ -> Just<CLPlacemark> in
                return .init(.init())
            }
            .map(\.address)
            .map { Optional($0) }
            .assign(to: &$address)
    }

    func fetchRockList() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Rock.colletionName)
            .getDocuments(FIDocument.Rock.self)
            .catch { error -> Just<[FIDocument.Rock]> in
                self.error = error
                return .init([])
            }
            .assign(to: &self.$rockDocuments)
    }
}
