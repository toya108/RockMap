//
//  StorageManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/17.
//

import FirebaseStorage
import Combine

struct StorageManager {
    
    typealias Reference = StorageReference
    
    static let reference = Storage.storage().reference()
    
    static func makeReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference.child(parent.name).child(child)
    }
    
    static func getAllReference(
        reference: StorageReference
    ) -> Future<[Reference], Error> {
        return .init { promise in
            reference.listAll { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                promise(.success(result.items))
            }
        }
    }
}

extension UIImageView {
    static func loadImage(
        _ imageView: UIImageView,
        reference: StorageReference
    ) {
        imageView.sd_setImage(
            with: reference,
            placeholderImage: UIImage.AssetsImages.noImage
        )
    }
}
