//
//  RockConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import CoreLocation
import Combine
import FirebaseFirestore

protocol RockConfirmViewModelModelProtocol: ViewModelProtocol {
    var input: RockConfirmViewModel.Input { get }
    var output: RockConfirmViewModel.Output { get }
}

final class RockConfirmViewModel: RockConfirmViewModelModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    let registerType: RockRegisterViewModel.RegisterType
    var rockDocument: FIDocument.Rock
    let header: ImageDataKind
    let images: [ImageDataKind]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()

    init(
        registerType: RockRegisterViewModel.RegisterType,
        rockDocument: FIDocument.Rock,
        header: ImageDataKind,
        images: [ImageDataKind]
    ) {
        self.registerType = registerType
        self.rockDocument = rockDocument
        self.header = header
        self.images = images
        bindImageUploader()
        bindInput()
    }

    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)
    }

    private func bindInput() {
        input.uploadImageSubject
            .sink(receiveValue: uploadImages)
            .store(in: &bindings)

        input.registerRockSubject
            .sink(receiveValue: registerRock)
            .store(in: &bindings)
    }

    private func uploadImages() {
        prepareHeaderUploading()
        prepareImagesUploading()
        uploader.start()
    }

    private func prepareHeaderUploading() {
        let headerReference = StorageManager.makeImageReferenceForUpload(
            destinationDocument: FINameSpace.Rocks.self,
            documentId: rockDocument.id,
            imageType: .header
        )
        switch header {
            case .data(let data):
                uploader.addData(
                    data: data.data,
                    reference: headerReference
                )
            case .storage(let storage):

                guard
                    let updateData = storage.updateData
                else {
                    return
                }

                storage.storageReference.delete()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {}
                    )
                    .store(in: &bindings)

                uploader.addData(
                    data: updateData,
                    reference: headerReference
                )
        }
    }

    private func prepareImagesUploading() {
        images.forEach { imageDataKind in
            switch imageDataKind {
                case .data(let data):
                    uploader.addData(
                        data: data.data,
                        reference: StorageManager.makeImageReferenceForUpload(
                            destinationDocument: FINameSpace.Rocks.self,
                            documentId: rockDocument.id,
                            imageType: .normal
                        )
                    )
                case .storage(let storage):

                    guard
                        storage.shouldUpdate
                    else {
                        return
                    }

                    storage.storageReference.delete()
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: {}
                        )
                        .store(in: &bindings)
            }
        }
    }

    private func registerRock() {
        output.rockUploadState = .loading

        switch registerType {
            case .create:
                createRock()

            case .edit:
                editRock()
        }
    }

    private func createRock() {
        rockDocument
            .makeDocumentReference()
            .setData(from: rockDocument)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &bindings)
    }

    private func editRock() {
        rockDocument
            .makeDocumentReference()
            .updateData(rockDocument.dictionary)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &bindings)
    }
}

extension RockConfirmViewModel {

    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerRockSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var rockUploadState: LoadingState<Void> = .stanby
    }
}
