//
//  RockConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import CoreLocation

final class RockConfirmViewModel {
    @Published var rockName: String
    @Published var rockImageDatas: [Data]
    @Published var rockAddress: String
    @Published var rockLocation: CLLocation
    @Published var rockDesc: String
    
    init (rockName: String, rockImageDatas: [Data], rockAddress: String, rockLocation: CLLocation, rockDesc: String) {
        self.rockName = rockName
        self.rockImageDatas = rockImageDatas
        self.rockAddress = rockAddress
        self.rockLocation = rockLocation
        self.rockDesc = rockDesc
    }
}
