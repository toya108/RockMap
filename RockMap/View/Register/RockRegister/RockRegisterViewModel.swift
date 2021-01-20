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
    
    private var rockAddressShared: Publishers.Share<Published<String>.Publisher> {
        return $rockAddress.share()
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
        
        rockAddressShared
            .dropFirst()
            .removeDuplicates()
            .sink { address in
                LocationManager.shared.geocoding(address: address) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let location):
                        self.rockLocation = location
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.rockAddressValidationResult = .invalid(.cannotConvertAddressToLocation)
                        
                    }
                }
            }
            .store(in: &bindings)
        
        rockAddressShared
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
