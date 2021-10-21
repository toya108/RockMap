import Auth
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
            .sink(receiveValue: self.uploadImages)
            .store(in: &self.bindings)

        self.input.registerRockSubject
            .sink(receiveValue: self.registerRock)
            .store(in: &self.bindings)
    }

    private var uploadImages: () -> Void {{ [weak self] in

        guard let self = self else { return }

        let writeHeader = self.writeImageUsecase.write(
            data: self.header.updateData,
            shouldDelete: self.header.shouldDelete,
            image: self.header.image
        ) {
            .rock
            self.rockEntity.id
            self.header.imageType
        }

        let writeImages = self.images.map {
            self.writeImageUsecase.write(
                data: $0.updateData,
                shouldDelete: $0.shouldDelete,
                image: $0.image
            ) {
                .rock
                self.rockEntity.id
                Entity.Image.ImageType.normal
                AuthManager.shared.uid
            }
        }

        let writeImagePublishers = [writeHeader] + writeImages

        Publishers.MergeMany(writeImagePublishers).collect()
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                print(error)
                self.output.imageUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in

                    guard let self = self else { return }

                    self.output.imageUploadState = .finish(content: ())
                }
            }
            .store(in: &self.bindings)
    }}

    private func registerRock() {
        self.output.rockUploadState = .loading

        switch self.registerType {
        case .create:
            self.createRock()

        case .edit:
            self.editRock()
        }
    }

    private func createRock() {
        self.setRockUsecase.set(rock: self.rockEntity)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }

    private func editRock() {
        self.updateRockUsecase.update(rock: self.rockEntity)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }
}

extension RockConfirmViewModel {
    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerRockSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var rockUploadState: LoadingState<Void> = .stanby
    }
}
