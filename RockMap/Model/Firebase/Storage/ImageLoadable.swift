//
//  GenericImage.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/07/27.
//

import Foundation

enum ImageLoadable: Hashable {
    case url(URL)
    case storage(StorageManager.Reference)
}
