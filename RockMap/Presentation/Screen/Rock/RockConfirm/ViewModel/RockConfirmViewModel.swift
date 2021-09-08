
import CoreLocation
import Combine
import FirebaseFirestore
import Auth

protocol RockConfirmViewModelModelProtocol: ViewModelProtocol {
    var input: RockConfirmViewModel.Input { get }
    var output: RockConfirmViewModel.Output { get }
}

final class RockConfirmViewModel: RockConfirmViewModelModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    let registerType: RockRegisterViewModel.RegisterType
    var rockEntity: Entity.Rock
    let header: CrudableImageV2
    let images: [CrudableImageV2]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()
    private let setRockUsecase = Usecase.Rock.Set()
    private let updateRockUsecase = Usecase.Rock.Update()
    private let writeImageUsecase = Usecase.Image.Write()

    init(
        registerType: RockRegisterViewModel.RegisterType,
        rockEntity: Entity.Rock,
        header: CrudableImageV2,
        images: [CrudableImageV2]
    ) {
        self.registerType = registerType
        self.rockEntity = rockEntity
        self.header = header
        self.images = images
        bindInput()
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

        let writeHeader = writeImageUsecase.write(
            data: header.updateData,
            shouldDelete: header.shouldDelete,
            image: header.image
        ) {
            .rock
            rockEntity.id
            header.imageType
        }

        let writeImages = images.map {
            writeImageUsecase.write(
                data: $0.updateData,
                shouldDelete: $0.shouldDelete,
                image: $0.image
            ) {
                .rock
                rockEntity.id
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
            .store(in: &bindings)
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
        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var rockUploadState: LoadingState<Void> = .stanby
    }
}
