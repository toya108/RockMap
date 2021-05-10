//
//  EditProfileViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//


import Combine
import Foundation

protocol EditProfileViewModelProtocol: ViewModelProtocol {
    var input: EditProfileViewModel.Input { get }
    var output: EditProfileViewModel.Output { get }
}

class EditProfileViewModel: EditProfileViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    let user: FIDocument.User

    private var bindings = Set<AnyCancellable>()

    init(user: FIDocument.User) {
        self.user = user
        bindInput()
        bindOutput()
    }

    private func bindInput() {
        input.nameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$name)

        input.introductionSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$introduction)

        input.setImageSubject
            .sink(receiveValue: setHeaderImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)
    }

    private func bindOutput() {
        output.$name
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$nameValidationResult)

        output.$header
            .dropFirst()
            .map {
                guard let imageDataKind = $0 else {
                    return nil
                }
                return imageDataKind.shouldAppendItem ? $0 : nil
            }
            .map { RockHeaderImageValidator().validate($0) }
            .assign(to: &output.$headerImageValidationResult)
    }

    private func fetchCourseStorage(courseId: String) {
//        let courseStorageReference = StorageManager.makeReference(
//            parent: FINameSpace.Course.self,
//            child: courseId
//        )
//        StorageManager
//            .getHeaderReference(courseStorageReference)
//            .catch { _ -> Just<StorageManager.Reference?> in
//                return .init(nil)
//            }
//            .compactMap { $0 }
//            .map { ImageDataKind.storage(.init(storageReference: $0)) }
//            .assign(to: &output.$header)
//
//        StorageManager.getNormalImagePrefixes(courseStorageReference)
//            .catch { _ -> Just<[StorageManager.Reference]> in
//                return .init([])
//            }
//            .sink { [weak self] prefixes in
//
//                guard let self = self else { return }
//
//                prefixes
//                    .map { $0.getReferences() }
//                    .forEach {
//                        $0.catch { _ -> Just<[StorageManager.Reference]> in
//                            return .init([])
//                        }
//                        .map {
//                            $0.map { ImageDataKind.storage(.init(storageReference: $0)) }
//                        }
//                        .assign(to: &self.output.$images)
//                    }
//            }
//            .store(in: &bindings)
    }

    private func setHeaderImage(kind: ImageDataKind) {
        switch output.header {
            case .data, .none:
                output.header = kind

            case .storage(var storage):
                storage.updateData = kind.data?.data
                storage.shouldUpdate = true
                output.header?.update(.storage(storage))
        }
    }

    private func deleteImage(_ imageStructure: ImageDataKind) {
        switch output.header {
            case .data:
                output.header = nil

            case .storage:
                output.header?.toggleStorageUpdateFlag()

            default:
                break
        }
    }

    func callValidations() -> Bool {
        if !output.headerImageValidationResult.isValid {
            let header: ImageDataKind? = {
                guard
                    let imageDataKind = output.header
                else {
                    return nil
                }
                return imageDataKind.shouldAppendItem ? output.header : nil
            }()

            output.headerImageValidationResult = RockHeaderImageValidator().validate(header)
        }

        return [
            output.nameValidationResult,
            output.headerImageValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }
}

extension EditProfileViewModel {

    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(ImageDataKind), Never>()
        let deleteImageSubject = PassthroughSubject<(ImageDataKind), Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: ImageDataKind?
        @Published var nameValidationResult: ValidationResult = .none
        @Published var headerImageValidationResult: ValidationResult = .none
    }
}
