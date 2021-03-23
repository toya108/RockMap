//
//  LocationManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import CoreLocation

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
        location: CLLocation,
        completion: @escaping (Result<CLPlacemark, ReverseGeocdingError>) -> Void
    ) {
        self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(.convertError(error)))
                return
            }
            
            guard
                let placemark = placemarks?.first
            else {
                completion(.failure(.noPlacemark))
                return
            }
            
            completion(.success(placemark))
        }
    }
    
    func geocoding(
        address: String,
        completion: @escaping (Result<CLLocation, GeocodingError>) -> Void
    ) {
        self.geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(.convertError(error)))
                return
            }
            
            guard
                let location = placemarks?.first?.location
            else {
                completion(.failure(.noPlacemark))
                return
            }
            
            completion(.success(location))
        }
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
