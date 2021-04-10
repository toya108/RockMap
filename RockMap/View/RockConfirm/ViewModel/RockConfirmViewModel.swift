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
    var rockHeaderImage: IdentifiableData
    var rockLocation: LocationManager.LocationStructure
    var rockDesc: String
    var seasons: Set<FIDocument.Rock.Season>
    var lithology: FIDocument.Rock.Lithology
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var rockUploadState: StoreUploadState = .stanby

    private var bindings = Set<AnyCancellable>()
    
    private let uploader = StorageUploader()
    
    init(
        rockName: String,
        rockImageDatas: [IdentifiableData],
        rockHeaderImage: IdentifiableData,
        rockLocation: LocationManager.LocationStructure,
        rockDesc: String,
        seasons: Set<FIDocument.Rock.Season>,
        lithology: FIDocument.Rock.Lithology
    ) {
        self.rockName = rockName
        self.rockImageDatas = rockImageDatas
        self.rockHeaderImage = rockHeaderImage
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

        let headerReference = reference
            .child(ImageType.header.typeName)
            .child(UUID().uuidString)
        uploader.addData(data: rockHeaderImage.data, reference: headerReference)

        let normalReference = reference
            .child(ImageType.normal.typeName)
            .child(AuthManager.uid)
        rockImageDatas.forEach {
            let imageReference = normalReference.child(UUID().uuidString)
            uploader.addData(data: $0.data, reference: imageReference)
        }

        uploader.start()
    }
    
    func registerRock() {
        
        rockUploadState = .loading

        let rockDocument = FIDocument.Rock(
            updatedAt: nil,
            parentPath: AuthManager.getAuthUserReference().path,
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
            registeredUserReference: AuthManager.getAuthUserReference()
        )

        rockDocument.makeDocumentReference()
            .setData(from: rockDocument)
            .catch { [weak self] error -> Just<Void> in

                guard let self = self else { return .init(()) }

                self.rockUploadState = .failure(error)
                return .init(())
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.rockUploadState = .finish
            }
            .store(in: &bindings)
    }
}
