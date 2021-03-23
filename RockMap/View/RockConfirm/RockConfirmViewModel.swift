//
//  RockConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import CoreLocation
import Combine
import FirebaseFirestore

final class RockConfirmViewModel {
    
    var rockName: String
    var rockImageDatas: [IdentifiableData]
    var rockLocation: LocationManager.LocationStructure
    var rockDesc: String
    var seasons: Set<FIDocument.Rock.Season>
    var lithology: FIDocument.Rock.Lithology
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var rockUploadState: StoreUploadState = .stanby
    
    private let uploader = StorageUploader()
    
    init(
        rockName: String,
        rockImageDatas: [IdentifiableData],
        rockLocation: LocationManager.LocationStructure,
        rockDesc: String,
        seasons: Set<FIDocument.Rock.Season>,
        lithology: FIDocument.Rock.Lithology
    ) {
        self.rockName = rockName
        self.rockImageDatas = rockImageDatas
        self.rockLocation = rockLocation
        self.rockDesc = rockDesc
        self.seasons = seasons
        self.lithology = lithology
        bindImageUploader()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &$imageUploadState)
    }
    
    func uploadImages() {
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Rocks.self,
            child: rockName
        )
        rockImageDatas.forEach {
            let imageReference = reference.child(UUID().uuidString)
            uploader.addData(data: $0.data, reference: imageReference)
        }
        uploader.start()
    }
    
    func registerRock() {
        
        rockUploadState = .loading

        let rock = FIDocument.Rock(
            id: UUID().uuidString,
            createdAt: Date(),
            updatedAt: nil,
            parentPath: FIDocument.Rock.makeParentPath(parentCollection: FIDocument.User.colletionName, documentId: AuthManager.uid),
            name: rockName,
            address: rockLocation.address,
            prefecture: rockLocation.prefecture,
            location: .init(
                latitude: rockLocation.location.coordinate.latitude,
                longitude: rockLocation.location.coordinate.longitude
            ),
            seasons: seasons,
            lithology: lithology,
            desc: rockDesc,
            registeredUserId: AuthManager.uid
        )
        
        let rockDocument = FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(AuthManager.uid)
            .collection(FIDocument.Rock.colletionName)
            .document(rock.id)
        
        rockDocument.setData(rock.dictionary) { [weak self] error in
            
            guard let self = self else { return }
            
            if let error = error {
                self.rockUploadState = .failure(error)
                return
            }
            
            self.rockUploadState = .finish
        }
    }
}
