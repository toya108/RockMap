//
//  CourseRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import Combine
import Foundation

class CourseRegisterViewModel: ViewModelProtocol {

    struct RockHeaderStructure: Hashable {
        let rock: FIDocument.Rock
        let rockImageReference: StorageManager.Reference
    }

    @Published var rockHeaderStructure: RockHeaderStructure
    @Published var courseName = ""
    @Published var grade: FIDocument.Course.Grade = .q10
    @Published var shape: Set<FIDocument.Course.Shape> = []
    @Published var header: IdentifiableData?
    @Published var images: [IdentifiableData] = []
    @Published var desc = ""
    @Published var isPrivate = false
    
    @Published private(set) var courseNameValidationResult: ValidationResult = .none
    @Published private(set) var courseImageValidationResult: ValidationResult = .none
    @Published private(set) var headerImageValidationResult: ValidationResult = .none

    private var bindings = Set<AnyCancellable>()

    init(rockHeaderStructure: RockHeaderStructure) {
        self.rockHeaderStructure = rockHeaderStructure
        setupBindings()
    }
    
    private func setupBindings() {
        $courseName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &$courseNameValidationResult)
        
        $images
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &$courseImageValidationResult)

        $headerImageValidationResult
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &$courseImageValidationResult)
    }
    
    func callValidations() -> Bool {
        headerImageValidationResult = RockHeaderImageValidator().validate(header)
        courseImageValidationResult = RockImageValidator().validate(images)
        courseNameValidationResult = CourseNameValidator().validate(courseName)

        return [
            courseNameValidationResult,
            courseImageValidationResult,
            headerImageValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    func set(data: [IdentifiableData], for imageType: ImageType) {
        switch imageType {
            case .header:
                header = data.first

            case .normal:
                images.append(contentsOf: data)

        }
    }
}
