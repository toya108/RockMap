//
//  CourseRegisterViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import Combine
import Foundation

protocol CourseRegisterViewModelProtocol: ViewModelProtocol {
    var input: CourseRegisterViewModel.Input { get }
    var output: CourseRegisterViewModel.Output { get }
}

class CourseRegisterViewModel: CourseRegisterViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

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
            .assign(to: &output.$courseNameValidationResult)
        
        $images
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &output.$courseImageValidationResult)

        output.$headerImageValidationResult
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &output.$courseImageValidationResult)
    }
    
    func callValidations() -> Bool {
        output.headerImageValidationResult = RockHeaderImageValidator().validate(header)
        output.courseImageValidationResult = RockImageValidator().validate(images)
        output.courseNameValidationResult = CourseNameValidator().validate(courseName)

        return [
            output.courseNameValidationResult,
            output.courseImageValidationResult,
            output.headerImageValidationResult
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

extension CourseRegisterViewModel {

    struct Input {

    }

    final class Output {
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
