//
//  CourseRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import Combine
import Foundation

class CourseRegisterViewModel {
    
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
    @Published var grade: FIDocument.Course.Grade = .q10
    @Published var images: [IdentifiableData] = []
    @Published var desc = ""
    @Published var isPrivate = false
    
    @Published private(set) var courseNameValidationResult: ValidationResult = .none
    @Published private(set) var courseImageValidationResult = false
    
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
            .assign(to: &$courseNameValidationResult)
        
        $images
            .dropFirst()
            .map { !$0.isEmpty }
            .assign(to: &$courseImageValidationResult)
    }
    
    func callValidations() -> Bool {
        courseImageValidationResult = !images.isEmpty
        courseNameValidationResult = CourseNameValidator().validate(courseName)
        
        return courseNameValidationResult.isValid && courseImageValidationResult
    }
}
