//
//  RockSearchViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/18.
//

import CoreLocation

class RockSearchViewModel {
    
    @Published private(set) var rockDocuments: [FIDocument.Rock] = []
    @Published private(set) var error: Error?
    @Published var location: CLLocation?
    @Published var locationSelectState: LocationSelectButtonState = .standby
    
    init() {
        fetchRockList()
    }
    
    func fetchRockList() {
        updatePrefectureIfNeeded {
            let collectionGroup = FirestoreManager.db.collectionGroup(FIDocument.Rock.colletionName)
            let query = collectionGroup.whereField("prefecture", isEqualTo: LocationManager.shared.prefecture)
            query.getDocuments { [weak self] snap, error in
                
                guard let self = self else { return }
                
                if
                    let error = error
                {
                    self.error = error
                    return
                }
                
                self.rockDocuments = snap?.documents.compactMap { FIDocument.Rock.initializeDocument(json: $0.data()) } ?? []
            }
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
