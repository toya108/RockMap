//
//  ImageType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/29.
//

enum ImageType {
    case header
    case normal

    var limit: Int {
        switch self {
            case .header:
                return 1
                
            default:
                return 10
        }
    }

    var typeName: String {
        switch self {
            case .header:
                return "header"

            case .normal:
                return "normal"

        }
    }
}

enum ImageDataKind: Hashable {
    case data(IdentifiableData)
    case storage(UpdatableStorage)

    mutating func toggleStorageUpdateFlag() {

        guard
            case var .storage(updatableStorage) = self
        else {
            return
        }

        updatableStorage.shouldUpdate.toggle()
        self = .storage(updatableStorage)
    }

    mutating func update(_ value: ImageDataKind) {

        switch (self, value) {
            case (.data, .data(let data)):
                self = .data(data)

            case (.storage, .storage(let storage)):
                self = .storage(storage)

            default:
                break
        }
    }

    var data: IdentifiableData? {

        guard
            case let .data(data) = self
        else {
            return nil
        }

        return data
    }

    var shouldAppendItem: Bool {
        switch self {
            case .data:
                return true

            case .storage(let storage):
                switch (storage.shouldUpdate, storage.updateData == nil) {
                    case (false, true), (true, false):
                        return true

                    default:
                        return false
                }
        }
    }
}
