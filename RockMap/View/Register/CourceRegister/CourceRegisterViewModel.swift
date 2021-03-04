//
//  CourceRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import Combine
import Foundation

class CourceRegisterViewModel {
    
    struct RockHeaderStructure: Hashable {
        let rockId: String
        let rockName: String
        let rockImageReference: StorageManager.Reference
        let userIconPhotoURL: URL?
        let userName: String
        
        init(
            rockId: String = "",
            rockName: String = "",
            rockImageReference: StorageManager.Reference = .init(),
            userIconPhotoURL: URL? = nil,
            userName: String = ""
        ) {
            self.rockId = rockId
            self.rockName = rockName
            self.rockImageReference = rockImageReference
            self.userIconPhotoURL = userIconPhotoURL
            self.userName = userName
        }
    }
    
    @Published var rockHeaderStructure = RockHeaderStructure()
    
    @Published var courseName = ""
    @Published var grade: FIDocument.Cource.Grade = .q10
    @Published var images: [IdentifiableData] = []
    @Published var desc = ""
    @Published var isPrivate = false
    
    @Published private(set) var courceNameValidationResult: ValidationResult = .none
    @Published private(set) var courceImageValidationResult = false
    
    private var bindings = Set<AnyCancellable>()

    init(rockHeaderStructure: RockHeaderStructure) {
        setupBindings()
        self.rockHeaderStructure = rockHeaderStructure
    }
    
    private func setupBindings() {
        $courseName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &$courceNameValidationResult)
        
        $images
            .dropFirst()
            .map { !$0.isEmpty }
            .assign(to: &$courceImageValidationResult)
    }
    
    func callValidations() -> Bool {
        courceImageValidationResult = !images.isEmpty
        courceNameValidationResult = CourseNameValidator().validate(courseName)
        
        return courceNameValidationResult.isValid && courceImageValidationResult
    }
}
