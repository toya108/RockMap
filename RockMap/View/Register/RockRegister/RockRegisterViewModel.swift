//
//  RockRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/02.
//

import Combine
import Foundation

final class RockRegisterViewModel {
    @Published var rockName = ""
    @Published var rockImageDatas: [Data] = []
    @Published var rockPoint = ""
    @Published var rockDesc = ""
    
    @Published private(set) var state: NetworkState = .standby
    @Published private(set) var rockNameValidationResult: ValidationResult = .none
    @Published private(set) var rockPointValidationResult: ValidationResult = .none
    @Published private(set) var isPassedAllValidation = false
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $rockName
            .removeDuplicates()
            .map { name -> ValidationResult in RockNameValidator().validate(name) }
            .assign(to: &$rockNameValidationResult)
    }
}
