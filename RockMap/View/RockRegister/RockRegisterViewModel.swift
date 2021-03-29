//
//  RockRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/02.
//

import Combine
import Foundation
import CoreLocation

final class RockRegisterViewModel {
    
    @Published var rockName = ""
    @Published var rockHeaderImage: IdentifiableData?
    @Published var rockImageDatas: [IdentifiableData] = []
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var rockDesc = ""
    @Published var seasons: Set<FIDocument.Rock.Season> = []
    @Published var lithology: FIDocument.Rock.Lithology = .unKnown

    @Published private(set) var rockNameValidationResult: ValidationResult = .none
    @Published private(set) var rockAddressValidationResult: ValidationResult = .none
    @Published private(set) var rockImageValidationResult: ValidationResult = .none
    @Published private(set) var headerImageValidationResult: ValidationResult = .none

    private var bindings = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }

    init(location: CLLocation) {
        setupBindings()
        self.rockLocation.location = location
    }
    
    private func setupBindings() {
        $rockName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in RockNameValidator().validate(name) }
            .assign(to: &$rockNameValidationResult)
        
        $rockLocation
            .removeDuplicates()
            .sink { locationStructure in
                LocationManager.shared.reverseGeocoding(location: locationStructure.location) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let placemark):
                        self.rockLocation.address = placemark.address
                        self.rockLocation.prefecture = placemark.prefecture
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.rockAddressValidationResult = .invalid(.cannotConvertLocationToAddrress)
                        
                    }
                }
            }
            .store(in: &bindings)
        
        $rockLocation
            .dropFirst()
            .removeDuplicates()
            .map { RockAddressValidator().validate($0.address) }
            .assign(to: &$rockAddressValidationResult)

        $rockHeaderImage
            .map { RockHeaderImageValidator().validate($0) }
            .assign(to: &$headerImageValidationResult)

        $rockImageDatas
            .map { RockImageValidator().validate($0) }
            .assign(to: &$rockImageValidationResult)
    }
    
    func callValidations() -> Bool {
        headerImageValidationResult = RockHeaderImageValidator().validate(rockHeaderImage)
        rockImageValidationResult = RockImageValidator().validate(rockImageDatas)
        rockNameValidationResult = RockNameValidator().validate(rockName)
        rockAddressValidationResult = RockAddressValidator().validate(rockLocation.address)

        let isPassedAllValidation = [
            headerImageValidationResult,
            rockImageValidationResult,
            rockNameValidationResult,
            rockAddressValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }

        return isPassedAllValidation
    }

    func set(data: [IdentifiableData], for imageType: ImageType) {
        switch imageType {
            case .header:
                rockHeaderImage = data.first

            case .normal:
                rockImageDatas.append(contentsOf: data)

        }
    }
}
