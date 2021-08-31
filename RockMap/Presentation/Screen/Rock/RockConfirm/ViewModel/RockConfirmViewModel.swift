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
    var rockEntity: Entity.Rock
    let header: CrudableImage
    let images: [CrudableImage]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    private let setRockUsecase = Usecase.Rock.Set()
    private let updateRockUsecase = Usecase.Rock.Update()

    init(
        registerType: RockRegisterViewModel.RegisterType,
        rockEntity: Entity.Rock,
        header: CrudableImage,
        images: [CrudableImage]
    ) {
        self.registerType = registerType
        self.rockEntity = rockEntity
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
        uploader.addData(
            image: header,
            id: rockEntity.id,
            documentType: FINameSpace.Rocks.self
        )
        images.forEach {
            uploader.addData(
                image: $0,
                id: rockEntity.id,
                documentType: FINameSpace.Rocks.self
            )
        }
        uploader.start()
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
        setRockUsecase.set(rock: rockEntity)
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
        updateRockUsecase.update(rock: rockEntity)
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
