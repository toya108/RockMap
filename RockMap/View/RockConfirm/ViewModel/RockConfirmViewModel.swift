//
//  RockConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import CoreLocation
import Combine
import FirebaseFirestore

final class RockConfirmViewModel: ViewModelProtocol {
    
    var rockName: String
    var rockImageDatas: [IdentifiableData]
    var rockHeaderImage: IdentifiableData
    var rockLocation: LocationManager.LocationStructure
    var rockDesc: String
    var seasons: Set<FIDocument.Rock.Season>
    var lithology: FIDocument.Rock.Lithology
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var rockUploadState: LoadingState  = .stanby

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
        uploader.addData(
            data: rockHeaderImage.data,
            reference: StorageManager.makeHeaderImageReference(
                parent: FINameSpace.Rocks.self,
                child: rockName
            )
        )
        rockImageDatas.forEach {
            uploader.addData(
                data: $0.data,
                reference: StorageManager.makeNormalImageReference(
                    parent: FINameSpace.Rocks.self,
                    child: rockName
                )
            )
        }
        uploader.start()
    }
    
    func registerRock() {
        
        rockUploadState = .loading

        let rockDocument = FIDocument.Rock(
            parentPath: AuthManager.shared.authUserReference.path,
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
            registeredUserReference: AuthManager.shared.authUserReference
        )

        rockDocument.makeDocumentReference()
            .setData(from: rockDocument)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.rockUploadState = .finish

                        case let .failure(error):
                            self.rockUploadState = .failure(error)

                    }
                },
                receiveValue: {}
            )
            .store(in: &bindings)
    }
}
