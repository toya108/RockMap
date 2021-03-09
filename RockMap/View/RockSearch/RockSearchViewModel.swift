//
//  RockSearchViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/18.
//

import Foundation

class RockSearchViewModel {
    
    @Published private(set) var rockDocuments: [FIDocument.Rock] = []
    @Published private(set) var error: Error?
    
    init() {
        fetchRockList()
    }
    
    func fetchRockList() {
        let rockCollectionGroup = FirestoreManager.db.collectionGroup(FIDocument.Rock.colletionName)
        rockCollectionGroup.getDocuments { [weak self] snap, error in
            
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
