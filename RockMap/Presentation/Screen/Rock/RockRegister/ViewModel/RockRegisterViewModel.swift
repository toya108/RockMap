import Combine
import CoreLocation
import Foundation

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
        self.bindInput()
        self.bindOutput()

        switch registerType {
        case let .create(location):
            guard
                let location = location
            else {
                return
            }
            self.input.locationSubject.send(.init(location: location))

        case let .edit(rock):
            self.input.rockNameSubject.send(rock.name)
            self.input.rockDescSubject.send(rock.desc)
            self.input.rockAreaSubject.send(rock.area)
            let location = LocationManager.LocationStructure(
                location: .init(
                    latitude: rock.location.latitude,
                    longitude: rock.location.longitude
                ),
                address: rock.address,
                prefecture: rock.prefecture
            )
            self.input.locationSubject.send(location)
            rock.seasons.forEach {
                input.selectSeasonSubject.send($0)
            }
            self.input.lithologySubject.send(rock.lithology)

            self.fetchRockStorage(rockId: rock.id)
        }
    }

    private func bindInput() {
        self.input.rockNameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$rockName)

        self.input.rockDescSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$rockDesc)

        self.input.rockAreaSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$area)

        self.input.locationSubject
            .removeDuplicates()
            .assign(to: &self.output.$rockLocation)

        self.input.selectSeasonSubject
            .sink { [weak self] season in

                guard let self = self else { return }

                if self.output.seasons.contains(season) {
                    self.output.seasons.removeAll { $0 == season  }
                } else {
                    self.output.seasons.append(season)
                }
            }
            .store(in: &self.bindings)

        self.input.lithologySubject
            .removeDuplicates()
            .assign(to: &self.output.$lithology)

        self.input.setImageSubject
            .sink(receiveValue: self.setImage)
            .store(in: &self.bindings)

        self.input.deleteImageSubject
            .sink(receiveValue: self.deleteImage)
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$rockName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in RockNameValidator().validate(name) }
            .assign(to: &self.output.$rockNameValidationResult)

        self.output.$rockLocation
            .removeDuplicates()
            .map(\.location)
            .flatMap {
                LocationManager.shared.reverseGeocoding(location: $0)
                    .catch { [weak self] error -> Empty in

                        guard let self = self else { return Empty()}

                        print(error.localizedDescription)
                        self.output
                            .rockAddressValidationResult =
                            .invalid(.cannotConvertLocationToAddrress)
                        return Empty()
                    }
            }
            .sink { [weak self] placemark in

                guard let self = self else { return }

                self.output.rockLocation.address = placemark.address
                self.output.rockLocation.prefecture = placemark.prefecture
            }
            .store(in: &self.bindings)

        self.output.$rockLocation
            .dropFirst()
            .removeDuplicates()
            .map { RockAddressValidator().validate($0.address) }
            .assign(to: &self.output.$rockAddressValidationResult)

        self.output.$images
            .dropFirst()
            .map { RockImageValidator().validate($0.filter(\.shouldDelete)) }
            .assign(to: &self.output.$rockImageValidationResult)

        self.output.$header
            .dropFirst()
            .map { HeaderValidator().validate($0) }
            .assign(to: &self.output.$headerImageValidationResult)
    }

    private func fetchRockStorage(rockId: String) {
        Task {
            do {
                let header = try await self.fetchHeaderUsecase.fetch(id: rockId, destination: .rock)
                self.output.header = .init(imageType: .header, image: header)
                let images = try await self.fetchImagesUsecase.fetch(id: rockId, destination: .rock)
                self.output.images = images.map { CrudableImage(imageType: .normal, image: $0) }
            } catch {
                print(error)
            }
        }
    }

    private var setImage: (Entity.Image.ImageType, Data) -> Void {{ [weak self] imageType, data in

        guard let self = self else { return }

        switch imageType {
        case .normal:
            let newImage = CrudableImage(
                updateData: data,
                shouldDelete: false,
                imageType: .normal,
                image: .init()
            )
            self.output.images.append(newImage)

        case .header:
            self.output.header.updateData = data
            self.output.header.shouldDelete = false

        case .icon, .unhandle:
            break
        }
    }}

    private var deleteImage: (CrudableImage) -> Void {{ [weak self] crudableImage in

        guard let self = self else { return }

        switch crudableImage.imageType {
        case .header:
            self.output.header.updateData = nil

            if self.output.header.image.url != nil {
                self.output.header.shouldDelete = true
            }

        case .normal:
            guard
                let index = self.output.images.firstIndex(of: crudableImage)
            else {
                return
            }

            if self.output.images[index].image.url != nil {
                self.output.images[index].updateData = nil
                self.output.images[index].shouldDelete = true
            } else {
                self.output.images.remove(at: index)
            }

        case .icon, .unhandle:
            break
        }
    }}

    func callValidations() -> Bool {
        if !self.output.rockAddressValidationResult.isValid {
            self.output.rockAddressValidationResult = RockAddressValidator()
                .validate(self.output.rockLocation.address)
        }
        if !self.output.rockNameValidationResult.isValid {
            self.output.rockNameValidationResult = RockNameValidator()
                .validate(self.output.rockName)
        }
        if !self.output.headerImageValidationResult.isValid {
            self.output.headerImageValidationResult = HeaderValidator().validate(self.output.header)
        }
        if !self.output.rockImageValidationResult.isValid {
            let images = self.output.images.filter(\.shouldDelete)
            self.output.rockImageValidationResult = RockImageValidator().validate(images)
        }

        let isPassedAllValidation = [
            output.headerImageValidationResult,
            self.output.rockImageValidationResult,
            self.output.rockNameValidationResult,
            self.output.rockAddressValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }

        return isPassedAllValidation
    }

    var rockEntity: Entity.Rock {
        switch self.registerType {
        case .create:
            return .init(
                id: UUID().uuidString,
                createdAt: Date(),
                name: self.output.rockName,
                area: self.output.area,
                address: self.output.rockLocation.address,
                prefecture: self.output.rockLocation.prefecture,
                location: .init(
                    latitude: self.output.rockLocation.location.coordinate.latitude,
                    longitude: self.output.rockLocation.location.coordinate.longitude
                ),
                seasons: self.output.seasons,
                lithology: self.output.lithology,
                desc: self.output.rockDesc,
                registeredUserId: AuthManager.shared.uid,
                imageUrls: []
            )

        case var .edit(rock):
            rock.name = self.output.rockName
            rock.desc = self.output.rockDesc
            rock.location = .init(
                latitude: self.output.rockLocation.location.coordinate.latitude,
                longitude: self.output.rockLocation.location.coordinate.longitude
            )
            rock.seasons = self.output.seasons
            rock.lithology = self.output.lithology
            rock.prefecture = self.output.rockLocation.prefecture
            rock.address = self.output.rockLocation.address
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
        let rockAreaSubject = PassthroughSubject<String?, Never>()
        let locationSubject = PassthroughSubject<LocationManager.LocationStructure, Never>()
        let selectSeasonSubject = PassthroughSubject<Entity.Rock.Season, Never>()
        let lithologySubject = PassthroughSubject<Entity.Rock.Lithology, Never>()
        let setImageSubject = PassthroughSubject<(Entity.Image.ImageType, Data), Never>()
        let deleteImageSubject = PassthroughSubject<CrudableImage, Never>()
    }

    final class Output {
        @Published var rockName = ""
        @Published var rockLocation = LocationManager.LocationStructure()
        @Published var rockDesc = ""
        @Published var area = ""
        @Published var seasons: [Entity.Rock.Season] = []
        @Published var lithology: Entity.Rock.Lithology = .unKnown
        @Published var header: CrudableImage = .init(imageType: .header)
        @Published var images: [CrudableImage] = []

        @Published var rockNameValidationResult: ValidationResult = .none
        @Published var rockAddressValidationResult: ValidationResult = .none
        @Published var rockImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
