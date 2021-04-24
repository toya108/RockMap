//
//  LoadingState.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

enum LoadingState {
    case stanby
    case loading
    case finish
    case failure(Error?)
}
