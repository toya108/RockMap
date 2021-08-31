//
//  RockAnnotation.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/28.
//

import MapKit

class RockAnnotation: NSObject, MKAnnotation {

    let rock: Entity.Rock
    let coordinate: CLLocationCoordinate2D
    var title: String?

    init(
        coordinate: CLLocationCoordinate2D,
        rock: Entity.Rock,
        title: String
    ) {
        self.rock = rock
        self.coordinate = coordinate
        self.title = title
    }
}
