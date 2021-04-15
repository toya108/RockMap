//
//  LocationManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import CoreLocation
import Combine

final class LocationManager: NSObject {
    
    struct LocationStructure: Equatable, Hashable {
        var location: CLLocation = LocationManager.shared.location
        var address: String = ""
        var prefecture: String = ""
    }
    
    static let shared = LocationManager()
    
    private override init() {}
    
    var isEnabledLocationServices: Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    var isAuthorized: Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    @Published var location = CLLocation(latitude: 35.6804, longitude: 139.7690)
    var prefecture: String = ""
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    private let geocoder = CLGeocoder()
    
    func requestWhenInUseAuthorization() {
        
        if isAuthorized { return }
        
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        
        guard let location = locations.first else { return }
        
        if self.location == location { return }
        
        self.location = location
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        locationManager.stopUpdatingLocation()
    }

    func reverseGeocoding(
        location: CLLocation
    ) -> AnyPublisher<CLPlacemark, ReverseGeocdingError> {

        Deferred {
            Future<CLPlacemark, ReverseGeocdingError> { promise in
                self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        promise(.failure(.convertError(error)))
                        return
                    }

                    guard
                        let placemark = placemarks?.first
                    else {
                        promise(.failure(.noPlacemark))
                        return
                    }

                    promise(.success(placemark))
                }
            }
        }
        .eraseToAnyPublisher()

    }

    func geocoding(
        address: String
    ) -> AnyPublisher<CLLocation, GeocodingError> {

        Deferred {
            Future<CLLocation, GeocodingError> { promise in
                self.geocoder.geocodeAddressString(address) { placemarks, error in
                    if let error = error {
                        promise(.failure(.convertError(error)))
                        return
                    }

                    guard
                        let location = placemarks?.first?.location
                    else {
                        promise(.failure(.noPlacemark))
                        return
                    }

                    promise(.success(location))
                }
            }
        }
        .eraseToAnyPublisher()

    }
}

enum ReverseGeocdingError: Error {
    case convertError(Error)
    case noPlacemark
}

enum GeocodingError: Error {
    case convertError(Error)
    case noPlacemark
}

extension CLPlacemark {
    var prefecture: String {
        administrativeArea ?? ""
    }
    
    var address: String {
        (administrativeArea ?? "") + (locality ?? "") + (name ?? "")
    }
}
