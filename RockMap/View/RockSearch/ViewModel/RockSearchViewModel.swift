//
//  RockSearchViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/18.
//

import CoreLocation
import Combine

class RockSearchViewModel {
    
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
            .sink { [weak self] location in

                guard
                    let self = self,
                    let location = location
                else {
                    return
                }

                LocationManager.shared.reverseGeocoding(
                    location: location
                ) { result in
                    switch result {
                        case let .success(placemark):
                            self.address = placemark.address
                            
                        case .failure:
                            break
                    }
                }
            }
            .store(in: &bindings)
    }

    func fetchRockList() {
        updatePrefectureIfNeeded { [weak self] in

            guard let self = self else { return }

            let collectionGroup = FirestoreManager.db.collectionGroup(FIDocument.Rock.colletionName)
            let query = collectionGroup.whereField("prefecture", isEqualTo: LocationManager.shared.prefecture)
            query.getDocuments(FIDocument.Rock.self)
                .catch { error -> Just<[FIDocument.Rock]> in
                    self.error = error
                    return .init([])
                }
                .assign(to: &self.$rockDocuments)
        }
    }
    
    private func updatePrefectureIfNeeded(completion: (() -> Void)? = nil) {
        
        guard
            LocationManager.shared.prefecture.isEmpty
        else {
            completion?()
            return
        }
        
        LocationManager.shared.reverseGeocoding(location: LocationManager.shared.location) { result in
            guard
                case let .success(placemark) = result
            else {
                completion?()
                return
            }
            
            if LocationManager.shared.prefecture == placemark.prefecture { return }
            
            LocationManager.shared.prefecture = placemark.prefecture
            completion?()
        }
    }
}
