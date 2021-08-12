//
//  Rock.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/15.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

extension FS.Document {

    struct Rock: DocumentProtocol, UserRegisterableDocumentProtocol {

        var collection: CollectionProtocol.Type { FS.Collection.Rocks.self }

        var id: String = UUID().uuidString
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var name: String
        var address: String
        var prefecture: String
        var location: GeoPoint
        var seasons: Set<String>
        var lithology: String
        var desc: String
        var registeredUserId: String
        @ExplicitNull var headerUrl: URL?
        var imageUrls: [URL] = []
    }
}
