import Combine
import CoreLocation
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
    private let setRockUsecase = Usecase.Rock.Set()
    private let updateRockUsecase = Usecase.Rock.Update()
    private let writeImageUsecase = Usecase.Image.Write()

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
        self.bindInput()
    }

    private func bindInput() {
        self.input.uploadImageSubject
            .asyncSink(receiveValue: uploadImages)
            .store(in: &self.bindings)

        self.input.registerRockSubject
            .asyncSink(receiveValue: registerRock)
            .store(in: &self.bindings)
    }

    private var uploadImages: () async -> Void {{ [weak self] in

        guard let self = self else { return }

        do {
            try await withThrowingTaskGroup(of: Void.self) { group in

                group.addTask { [weak self] in

                    guard let self = self else { return }

                    try await self.writeImageUsecase.write(
                        data: self.header.updateData,
                        shouldDelete: self.header.shouldDelete,
                        image: self.header.image
                    ) {
                        .rock
                        self.rockEntity.id
                        self.header.imageType
                    }
                }

                for image in self.images {
                    group.addTask { [weak self] in

                        guard let self = self else { return }

                        try await self.writeImageUsecase.write(
                            data: image.updateData,
                            shouldDelete: image.shouldDelete,
                            image: image.image
                        ) {
                            .rock
                            self.rockEntity.id
                            Entity.Image.ImageType.normal
                            AuthManager.shared.uid
                        }
                    }
                }

                while let _ = try await group.next() {}
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in

                guard let self = self else { return }

                self.output.imageUploadState = .finish(content: ())
            }
        } catch {
            self.output.imageUploadState = .failure(error)
        }
    }}

    private var registerRock: () async -> Void {{ [weak self] in

        guard let self = self else { return }

        self.output.rockUploadState = .loading

        switch self.registerType {
            case .create:
                await self.createRock()

            case .edit:
                await self.editRock()
        }
    }}

    private func createRock() async {
        do {
            try await self.setRockUsecase.set(rock: self.rockEntity)
            self.output.rockUploadState = .finish(content: ())
        } catch {
            self.output.rockUploadState = .failure(error)
        }
    }

    private func editRock() async {
        do {
            try await self.updateRockUsecase.update(rock: self.rockEntity)
            self.output.rockUploadState = .finish(content: ())
        } catch {
            self.output.rockUploadState = .failure(error)
        }
    }
}

extension RockConfirmViewModel {
    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerRockSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: LoadingState<Void> = .standby
        @Published var rockUploadState: LoadingState<Void> = .standby
    }
}
