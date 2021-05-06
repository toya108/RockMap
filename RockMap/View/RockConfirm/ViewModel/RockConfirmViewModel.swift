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
    
    let rockName: String
    let rockImageDatas: [IdentifiableData]
    let rockHeaderImage: IdentifiableData
    let rockLocation: LocationManager.LocationStructure
    let rockDesc: String
    let seasons: Set<FIDocument.Rock.Season>
    let lithology: FIDocument.Rock.Lithology

    private let rockDocument: FIDocument.Rock

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

        self.rockDocument = FIDocument.Rock(
            parentPath: AuthManager.shared.authUserReference?.path ?? "",
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
            registedUserId: AuthManager.shared.uid
        )
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
                child: rockDocument.id
            )
        )
        rockImageDatas.forEach {
            uploader.addData(
                data: $0.data,
                reference: StorageManager.makeNormalImageReference(
                    parent: FINameSpace.Rocks.self,
                    child: rockDocument.id
                )
            )
        }
        uploader.start()
    }
    
    func registerRock() {
        
        rockUploadState = .loading

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
