//
//  RockRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/02.
//

import Combine
import Foundation
import CoreLocation

protocol RockRegisterViewModelProtocol: ViewModelProtocol {
    var input: RockRegisterViewModel.Input { get }
    var output: RockRegisterViewModel.Output { get }
}

final class RockRegisterViewModel: RockRegisterViewModelProtocol {

    var input = Input()
    var output = Output()

    let registerType: RegisterType

    private var bindings = Set<AnyCancellable>()

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
            .removeDuplicates()
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
            .map { RockImageValidator().validate($0.filter(\.shouldAppendItem)) }
            .assign(to: &output.$rockImageValidationResult)

        output.$header
            .dropFirst()
            .map {
                guard let imageDataKind = $0 else {
                    return nil
                }
                return imageDataKind.shouldAppendItem ? $0 : nil
            }
            .map { RockHeaderImageValidator().validate($0) }
            .assign(to: &output.$headerImageValidationResult)

    }

    private func fetchRockStorage(rockId: String) {
        let courseStorageReference = StorageManager.makeReference(
            parent: FINameSpace.Rocks.self,
            child: rockId
        )
        StorageManager
            .getHeaderReference(courseStorageReference)
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .compactMap { $0 }
            .map { ImageDataKind.storage(.init(storageReference: $0)) }
            .assign(to: &output.$header)

        StorageManager.getNormalImagePrefixes(courseStorageReference)
            .catch { _ -> Just<[StorageManager.Reference]> in
                return .init([])
            }
            .flatMap { $0.getReferences() }
            .catch { _ -> Just<[StorageManager.Reference]> in
                return .init([])
            }
            .map {
                $0.map { ImageDataKind.storage(.init(storageReference: $0)) }
            }
            .assign(to: &self.output.$images)
    }

    private func setImage(_ imageStructure: ImageStructure) {
        switch imageStructure.imageType {
            case .header:
                setHeaderImage(kind: imageStructure.imageDataKind)

            case .normal:
                setNormalImage(kind: imageStructure.imageDataKind)
        }
    }

    private func setHeaderImage(kind: ImageDataKind) {
        switch output.header {
            case .data, .none:
                output.header = kind

            case .storage(var storage):
                storage.updateData = kind.data?.data
                storage.shouldUpdate = true
                output.header?.update(.storage(storage))
        }
    }

    private func setNormalImage(kind: ImageDataKind) {
        self.output.images.append(kind)
    }

    private func deleteImage(_ imageStructure: ImageStructure) {
        switch imageStructure.imageType {
            case .header:
                deleteHeaderImage()

            case .normal:
                deleteNormalImage(target: imageStructure.imageDataKind)
        }
    }

    private func deleteHeaderImage() {
        switch output.header {
            case .data:
                output.header = nil

            case .storage:
                output.header?.toggleStorageUpdateFlag()

            default:
                break
        }
    }

    private func deleteNormalImage(target: ImageDataKind) {

        guard
            let index = self.output.images.firstIndex(of: target)
        else {
            return
        }

        switch target {
            case .data:
                self.output.images.remove(at: index)

            case .storage:
                self.output.images[index].toggleStorageUpdateFlag()
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
            let header: ImageDataKind? = {
                guard
                    let imageDataKind = output.header
                else {
                    return nil
                }
                return imageDataKind.shouldAppendItem ? output.header : nil
            }()

            output.headerImageValidationResult = RockHeaderImageValidator().validate(header)
        }
        if !output.rockImageValidationResult.isValid {
            let images = output.images.filter(\.shouldAppendItem)
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

    func makeRockDocument() -> FIDocument.Rock {
        switch registerType {
            case .create:
                return .init(
                    parentPath: AuthManager.shared.authUserReference?.path ?? "",
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
                    registedUserId: AuthManager.shared.uid
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
        case edit(FIDocument.Rock)

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
        let selectSeasonSubject = PassthroughSubject<FIDocument.Rock.Season, Never>()
        let lithologySubject = PassthroughSubject<FIDocument.Rock.Lithology, Never>()
        let setImageSubject = PassthroughSubject<(ImageStructure), Never>()
        let deleteImageSubject = PassthroughSubject<(ImageStructure), Never>()
    }

    final class Output {
        @Published var rockName = ""
        @Published var rockLocation = LocationManager.LocationStructure()
        @Published var rockDesc = ""
        @Published var seasons: Set<FIDocument.Rock.Season> = []
        @Published var lithology: FIDocument.Rock.Lithology = .unKnown
        @Published var header: ImageDataKind?
        @Published var images: [ImageDataKind] = []

        @Published var rockNameValidationResult: ValidationResult = .none
        @Published var rockAddressValidationResult: ValidationResult = .none
        @Published var rockImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
