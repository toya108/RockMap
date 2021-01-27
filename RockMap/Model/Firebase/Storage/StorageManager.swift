//
//  StorageManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/17.
//

import FirebaseStorage

struct StorageManager {
    static let reference = Storage.storage().reference()
    
    static func makeReference(parent: FINameSpaceProtocol.Type, child: String) -> StorageReference {
        Self.reference.child(parent.name).child(child)
    }
    
    static func getAllImageReference(reference: StorageReference, completion: @escaping (Result<[StorageReference], Error>) -> Void) {
        reference.listAll { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(result.items))
        }
    }
    
    static func getImage(reference: StorageReference, completion: @escaping (Result<Data, Error>) -> Void) {
        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if let error = error {
                print("画像のDLに失敗しました\(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("画像のdataを取得できませんでした。")
                return
            }
            
            completion(.success(data))
        }
    }
}
