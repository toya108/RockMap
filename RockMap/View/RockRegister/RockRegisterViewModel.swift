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
    @Published var rockImageDatas: [Data] = []
    @Published var rockAddress = ""
    @Published var rockLocation = LocationManager.shared.location
    @Published var rockDesc = ""
    
    @Published private(set) var rockNameValidationResult: ValidationResult = .none
    @Published private(set) var rockAddressValidationResult: ValidationResult = .none
    @Published private(set) var rockImageValidationResult = false
    @Published private(set) var isPassedAllValidation = false
    
    private var rockLocationShared: Publishers.Share<Published<CLLocation>.Publisher> {
        return $rockLocation.share()
    }
    
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
        
        rockLocationShared
            .dropFirst()
            .removeDuplicates()
            .sink { location in
                LocationManager.shared.reverseGeocoding(location: location) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let address):
                        self.rockAddress = address
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.rockAddressValidationResult = .invalid(.cannotConvertLocationToAddrress)
                        
                    }
                }
            }
            .store(in: &bindings)
        
        $rockAddress
            .dropFirst()
            .removeDuplicates()
            .map { address -> ValidationResult in RockAddressValidator().validate(address) }
            .assign(to: &$rockAddressValidationResult)
        
        $rockImageDatas
            .map { !$0.isEmpty }
            .assign(to: &$rockImageValidationResult)
        
        $rockNameValidationResult
            .combineLatest($rockImageValidationResult, $rockAddressValidationResult)
            .map { [$0.0.isValid, $0.1, $0.2.isValid].allSatisfy { $0 } }
            .assign(to: &$isPassedAllValidation)
    }
}
