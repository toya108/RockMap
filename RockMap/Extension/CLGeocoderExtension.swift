//
//  CLGeocoderExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/07.
//

import Combine
import CoreLocation

extension CLGeocoder {
    static func reverseGeocode(location: CLLocation) -> Future<String, ReverseGeocdingError> {
        return .init { promise in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(.convertError(error)))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    promise(.failure(.noPlacemark))
                    return
                }
                
                let administrativeArea = placemark.administrativeArea ?? ""
                let locality = placemark.locality ?? ""
                let name = placemark.name ?? ""

                promise(.success(administrativeArea + locality + name))
            }
        }
    }
}

enum ReverseGeocdingError: Error {
    case convertError(Error)
    case noPlacemark
}
