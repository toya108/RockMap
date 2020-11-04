//
//  NetWorkState.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

enum NetworkState {
    case standby
    case loading
    case finished(Any)
    case error(Error)
}
