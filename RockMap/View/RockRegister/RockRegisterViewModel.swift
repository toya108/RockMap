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
    @Published var rockImageDatas: [IdentifiableData] = []
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var rockDesc = ""
    @Published var seasons: Set<FIDocument.Rock.Season> = []
    @Published var lithology: FIDocument.Rock.Lithology = .unKnown

    @Published private(set) var rockNameValidationResult: ValidationResult = .none
    @Published private(set) var rockAddressValidationResult: ValidationResult = .none
    @Published private(set) var rockImageValidationResult = false
    @Published private(set) var isPassedAllValidation = false
    
    private var bindings = Set<AnyCancellable>()
    
    init() {
        setupBindings()
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
                    case .success(let address):
                        self.rockLocation.address = address
                        
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
            .map { locationStructure -> ValidationResult in
                RockAddressValidator().validate(locationStructure.address)
            }
            .assign(to: &$rockAddressValidationResult)

        $rockImageDatas
            .map { !$0.isEmpty }
            .assign(to: &$rockImageValidationResult)
        
        $rockNameValidationResult
            .combineLatest($rockImageValidationResult, $rockAddressValidationResult)
            .map { [$0.0.isValid, $0.1, $0.2.isValid].allSatisfy { $0 } }
            .assign(to: &$isPassedAllValidation)
    }
    
    func callValidations() -> Bool {
        rockImageValidationResult = !rockImageDatas.isEmpty
        rockNameValidationResult = RockNameValidator().validate(rockName)
        rockAddressValidationResult = RockAddressValidator().validate(rockLocation.address)
        
        return isPassedAllValidation
    }
}
