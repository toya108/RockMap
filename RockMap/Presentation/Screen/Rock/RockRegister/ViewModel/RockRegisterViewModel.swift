
import Auth
import Combine
import Foundation
import CoreLocation

protocol RockRegisterViewModelProtocol: ViewModelProtocol {
    var input: RockRegisterViewModel.Input { get }
    var output: RockRegisterViewModel.Output { get }
}

final class RockRegisterViewModel: RockRegisterViewModelProtocol {

    private typealias HeaderValidator = HeaderImageValidator

    var input = Input()
    var output = Output()

    let registerType: RegisterType

    private var bindings = Set<AnyCancellable>()
    private let fetchHeaderUsecase = Usecase.Image.Fetch.Header()
    private let fetchImagesUsecase = Usecase.Image.Fetch.Normal()

    init(registerType: RegisterType) {
        self.registerType = registerType
        bindInput()
        bindOutput()

        switch registerType {
            case let .create(location):
                guard
                    let location = location
                else {
                    return
                }
                input.locationSubject.send(.init(location: location))

            case let .edit(rock):
                input.rockNameSubject.send(rock.name)
                input.rockDescSubject.send(rock.desc)
                let location = LocationManager.LocationStructure(
                    location: .init(
                        latitude: rock.location.latitude,
                        longitude: rock.location.longitude
                    ),
                    address: rock.address,
                    prefecture: rock.prefecture
                )
                input.locationSubject.send(location)
                rock.seasons.forEach {
                    input.selectSeasonSubject.send($0)
                }
                input.lithologySubject.send(rock.lithology)

                fetchRockStorage(rockId: rock.id)
        }


    }

    private func bindInput() {
        input.rockNameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$rockName)

        input.rockDescSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$rockDesc)

        input.locationSubject
            .removeDuplicates()
            .assign(to: &output.$rockLocation)

        input.selectSeasonSubject
            .sink { [weak self] in

                guard let self = self else { return }

                if self.output.seasons.contains($0) {
                    self.output.seasons.remove($0)
                } else {
                    self.output.seasons.insert($0)
                }
            }
            .store(in: &bindings)

        input.lithologySubject
            .removeDuplicates()
            .assign(to: &output.$lithology)

        input.setImageSubject
            .sink(receiveValue: setImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)
    }

    private func bindOutput() {

        output.$rockName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in RockNameValidator().validate(name) }
            .assign(to: &output.$rockNameValidationResult)

        output.$rockLocation
            .removeDuplicates()
            .map(\.location)
            .flatMap {
                LocationManager.shared.reverseGeocoding(location: $0)
            }
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            break

                        case .failure(let error):
                            print(error.localizedDescription)
                            self.output.rockAddressValidationResult = .invalid(.cannotConvertLocationToAddrress)
                    }

                },
                receiveValue: { [weak self] placemark in

                    guard let self = self else { return }

                    self.output.rockLocation.address = placemark.address
                    self.output.rockLocation.prefecture = placemark.prefecture
                }
            )
            .store(in: &bindings)

        output.$rockLocation
            .dropFirst()
            .removeDuplicates()
            .map { RockAddressValidator().validate($0.address) }
            .assign(to: &output.$rockAddressValidationResult)

        output.$images
            .dropFirst()
            .map { RockImageValidator().validate($0.filter(\.shouldDelete)) }
            .assign(to: &output.$rockImageValidationResult)

        output.$header
            .dropFirst()
            .map { HeaderValidator().validate($0) }
            .assign(to: &output.$headerImageValidationResult)

    }

    private func fetchRockStorage(rockId: String) {

        fetchHeaderUsecase.fetch(id: rockId, destination: .rock)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { CrudableImage(imageType: .header, image: $0) }
            .assign(to: &output.$header)

        fetchImagesUsecase.fetch(id: rockId, destination: .rock)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map {
                $0.map { .init(imageType: .normal, image: $0) }
            }
            .assign(to: &self.output.$images)
    }

    private func setImage(imageType: Entity.Image.ImageType, data: Data) {

        switch imageType {
            case .normal:
                let newImage = CrudableImage(
                    updateData: data,
                    shouldDelete: false,
                    imageType: .normal,
                    image: .init()
                )
                output.images.append(newImage)

            case .header:
                output.header.updateData = data
                output.header.shouldDelete = false

            case .icon, .unhandle:
                break
        }
    }

    private func deleteImage(_ crudableImage: CrudableImage) {
        switch crudableImage.imageType {
            case .header:
                output.header.updateData = nil

                if output.header.image.url != nil {
                    output.header.shouldDelete = true
                }

            case .normal:
                if let index = output.images.firstIndex(of: crudableImage) {
                    if output.images[index].image.url != nil {
                        output.images[index].updateData = nil
                        output.images[index].shouldDelete = true
                    } else {
                        output.images.remove(at: index)
                    }
                }

            case .icon, .unhandle:
                break
        }
    }
    
    func callValidations() -> Bool {
        if !output.rockAddressValidationResult.isValid {
            output.rockAddressValidationResult = RockAddressValidator().validate(output.rockLocation.address)
        }
        if !output.rockNameValidationResult.isValid {
            output.rockNameValidationResult = RockNameValidator().validate(output.rockName)
        }
        if !output.headerImageValidationResult.isValid {
            output.headerImageValidationResult = HeaderValidator().validate(output.header)
        }
        if !output.rockImageValidationResult.isValid {
            let images = output.images.filter(\.shouldDelete)
            output.rockImageValidationResult = RockImageValidator().validate(images)
        }

        let isPassedAllValidation = [
            output.headerImageValidationResult,
            output.rockImageValidationResult,
            output.rockNameValidationResult,
            output.rockAddressValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }

        return isPassedAllValidation
    }

    var rockEntity: Entity.Rock {
        switch registerType {
            case .create:
                return .init(
                    id: UUID().uuidString,
                    createdAt: Date(),
                    parentPath: AuthManager.shared.userPath,
                    name: output.rockName,
                    address: output.rockLocation.address,
                    prefecture: output.rockLocation.prefecture,
                    location: .init(
                        latitude: output.rockLocation.location.coordinate.latitude,
                        longitude: output.rockLocation.location.coordinate.longitude
                    ),
                    seasons: output.seasons,
                    lithology: output.lithology,
                    desc: output.rockDesc,
                    registeredUserId: AuthManager.shared.uid,
                    imageUrls: []
                )

            case var .edit(rock):
                rock.name = output.rockName
                rock.desc = output.rockDesc
                rock.location = .init(
                    latitude: output.rockLocation.location.coordinate.latitude,
                    longitude: output.rockLocation.location.coordinate.longitude
                )
                rock.seasons = output.seasons
                rock.lithology = output.lithology
                rock.prefecture = output.rockLocation.prefecture
                rock.address = output.rockLocation.address
                return rock
        }
    }
}

extension RockRegisterViewModel {

    enum RegisterType {
        case create(CLLocation?)
        case edit(Entity.Rock)

        var name: String {
            switch self {
                case .create:
                    return "作成"
                case .edit:
                    return "編集"
            }
        }
    }

}

extension RockRegisterViewModel {

    struct Input {
        let rockNameSubject = PassthroughSubject<String?, Never>()
        let rockDescSubject = PassthroughSubject<String?, Never>()
        let locationSubject = PassthroughSubject<LocationManager.LocationStructure, Never>()
        let selectSeasonSubject = PassthroughSubject<Entity.Rock.Season, Never>()
        let lithologySubject = PassthroughSubject<Entity.Rock.Lithology, Never>()
        let setImageSubject = PassthroughSubject<(Entity.Image.ImageType, Data), Never>()
        let deleteImageSubject = PassthroughSubject<(CrudableImage), Never>()
    }

    final class Output {
        @Published var rockName = ""
        @Published var rockLocation = LocationManager.LocationStructure()
        @Published var rockDesc = ""
        @Published var seasons: Set<Entity.Rock.Season> = []
        @Published var lithology: Entity.Rock.Lithology = .unKnown
        @Published var header: CrudableImage = .init(imageType: .header)
        @Published var images: [CrudableImage] = []

        @Published var rockNameValidationResult: ValidationResult = .none
        @Published var rockAddressValidationResult: ValidationResult = .none
        @Published var rockImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
