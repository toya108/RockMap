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

    let rockHeaderStructure: RockHeaderStructure

    private var bindings = Set<AnyCancellable>()

    init(rockHeaderStructure: RockHeaderStructure) {
        self.rockHeaderStructure = rockHeaderStructure
        bindInput()
        bindOutput()
    }

    private func bindInput() {
        input.courseNameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$courseName)

        input.courseDescSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$courseDesc)

        input.gradeSubject
            .removeDuplicates()
            .assign(to: &output.$grade)

        input.shapeSubject
            .sink { [weak self] shape in

                guard let self = self else { return }

                if self.output.shape.contains(shape) {
                    self.output.shape.remove(shape)
                } else {
                    self.output.shape.insert(shape)
                }
            }
            .store(in: &bindings)

        input.setImageSubject
            .sink { [weak self] imageStructure in

                guard let self = self else { return }

                switch imageStructure.imageType {
                    case .header:
                        self.output.header = imageStructure.dataList.first

                    case .normal:
                        self.output.images.append(contentsOf: imageStructure.dataList)
                }
            }
            .store(in: &bindings)

        input.deleteImageSubject
            .sink { [weak self] imageStructure in

                guard let self = self else { return }

                switch imageStructure.imageType {
                    case .header:
                        self.output.header = nil

                    case .normal:
                        guard
                            let imageData = imageStructure.dataList.first,
                            let index = self.output.images.firstIndex(of: imageData)
                        else {
                            return
                        }
                        self.output.images.remove(at: index)
                }
            }
            .store(in: &bindings)
    }
    
    private func bindOutput() {
        output.$courseName
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$courseNameValidationResult)
        
        output.$images
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &output.$courseImageValidationResult)

        output.$headerImageValidationResult
            .dropFirst()
            .map { RockImageValidator().validate($0) }
            .assign(to: &output.$courseImageValidationResult)
    }
    
    func callValidations() -> Bool {
        output.headerImageValidationResult = RockHeaderImageValidator().validate(output.header)
        output.courseImageValidationResult = RockImageValidator().validate(output.images)
        output.courseNameValidationResult = CourseNameValidator().validate(output.courseName)

        return [
            output.courseNameValidationResult,
            output.courseImageValidationResult,
            output.headerImageValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }
}

extension CourseRegisterViewModel {

    struct Input {
        let courseNameSubject = PassthroughSubject<String?, Never>()
        let courseDescSubject = PassthroughSubject<String?, Never>()
        let gradeSubject = PassthroughSubject<FIDocument.Course.Grade, Never>()
        let shapeSubject = PassthroughSubject<FIDocument.Course.Shape, Never>()
        let setImageSubject = PassthroughSubject<(ImageStructure), Never>()
        let deleteImageSubject = PassthroughSubject<(ImageStructure), Never>()
    }

    final class Output {
        @Published var courseName = ""
        @Published var courseDesc = ""
        @Published var grade = FIDocument.Course.Grade.q10
        @Published var shape = Set<FIDocument.Course.Shape>()
        @Published var header: IdentifiableData?
        @Published var images: [IdentifiableData] = []
        @Published var courseNameValidationResult: ValidationResult = .none
        @Published var courseImageValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
