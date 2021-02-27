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
        let rockName: String
        let rockImageReference: StorageManager.Reference
        let userIconPhotoURL: URL?
        let userName: String
        
        init(
            rockName: String = "",
            rockImageReference: StorageManager.Reference = .init(),
            userIconPhotoURL: URL? = nil,
            userName: String = ""
        ) {
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
        
    }
}
