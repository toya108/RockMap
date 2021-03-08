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
    var rockImageDatas: [Data]
    var rockAddress: String
    var rockLocation: CLLocation
    var rockDesc: String
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var rockUploadState: StoreUploadState = .stanby
    
    private let uploader = StorageUploader()
    
    init(rockName: String, rockImageDatas: [Data], rockAddress: String, rockLocation: CLLocation, rockDesc: String) {
        self.rockName = rockName
        self.rockImageDatas = rockImageDatas
        self.rockAddress = rockAddress
        self.rockLocation = rockLocation
        self.rockDesc = rockDesc
        bindImageUploader()
    }
    
    init() {
        self.rockName = ""
        self.rockImageDatas = []
        self.rockAddress = ""
        self.rockLocation = .init(latitude: 0, longitude: 0)
        self.rockDesc = ""
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
            uploader.addData(data: $0, reference: imageReference)
        }
        uploader.start()
    }
    
    func registerRock() {
        
        rockUploadState = .loading

        let rockDocument = FIDocument.Rock(
            id: UUID().uuidString,
            name: rockName,
            address: rockAddress,
            location: .init(
                latitude: rockLocation.coordinate.latitude,
                longitude: rockLocation.coordinate.longitude
            ),
            desc: rockDesc,
            registeredUserId: AuthManager.uid,
            courses: []
        )
        
        let colle = FirestoreManager.db.collection(FIDocument.User.colletionName).document(AuthManager.uid).collection(FIDocument.Rock.colletionName)
        colle.addDocument(data: rockDocument.dictionary)
//        userDocument.setData(["createdRock": FieldValue.arrayUnion([rockDocument])]) {error in
//            print(error)
//        }
//        FirestoreManager.db.runTransaction({ (transaction, errorPointer) -> Any? in
////            let snap: DocumentSnapshot
//            
////            do {
////                try snap = transaction.getDocument(userDocument)
////            } catch let fetchError as NSError {
////                errorPointer?.pointee = fetchError
////                return nil
////            }
//            
//            transaction.updateData(["createdRock": [rockDocument]], forDocument: userDocument)
//            return rockDocument
//        }) { _, error in
//            if let error = error {
//                self.rockUploadState = .failure(error)
//                return
//            }
//            
//            self.rockUploadState = .finish
//
//        }
//        FirestoreManager.set(
//            key: rockDocument.id,
//            rockDocument
//        ) { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success:
//                self.rockUploadState = .finish
//
//            case .failure(let error):
//                self.rockUploadState = .failure(error)
//
//            }
//        }
    }
}
