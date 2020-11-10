//
//  LocationManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import CoreLocation

final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    private override init() {}
    
    var isEnabledLocationServices: Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    var isAuthorized: Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    var location = CLLocation(latitude: .zero, longitude: .zero)
    var address = ""
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    private let geocoder = CLGeocoder()
    
    /// パーミッション許可のダイアログを表示する
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        self.location = location
        
        reverseGeocoding(location: location) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let address):
                self.address = address
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func reverseGeocoding(location: CLLocation, completion: @escaping (Result<String, GeocodingError>) -> Void) {
        self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(.convertError(error)))
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(.failure(.noPlacemark))
                return
            }
            
            let administrativeArea = placemark.administrativeArea ?? ""
            let locality = placemark.locality ?? ""
            let name = placemark.name ?? ""
            completion(.success(administrativeArea + locality + name))
        }
    }
    
    func geocoding(address: String, completion: @escaping (Result<CLLocation, GeocodingError>) -> Void) {
        self.geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(.convertError(error)))
                return
            }
            
            guard let location = placemarks?.first?.location else {
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
