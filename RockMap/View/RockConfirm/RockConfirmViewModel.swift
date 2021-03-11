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
    var rockAddress: String
    var rockLocation: LocationManager.LocationStructure
    var rockDesc: String
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var rockUploadState: StoreUploadState = .stanby
    
    private let uploader = StorageUploader()
    
    init(
        rockName: String,
        rockImageDatas: [IdentifiableData],
        rockAddress: String,
        rockLocation: LocationManager.LocationStructure,
        rockDesc: String
    ) {
        self.rockName = rockName
        self.rockImageDatas = rockImageDatas
        self.rockAddress = rockAddress
        self.rockLocation = rockLocation
        self.rockDesc = rockDesc
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
            name: rockName,
            address: rockAddress,
            location: .init(
                latitude: rockLocation.location.coordinate.latitude,
                longitude: rockLocation.location.coordinate.longitude
            ),
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
