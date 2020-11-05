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

    var authorizationHandler: ((Bool) -> Void)?
    var requestStartHandler: (() -> Void)?
    var completionHandler: (([CLLocation]) -> Void)?
    var errorHandler: ((Error) -> Void)?
    static var isEnabledLocationServices: Bool { CLLocationManager.locationServicesEnabled() }

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return manager
    }()

    func requestLocation() {
        requestStartHandler?()

    }

    /// パーミッション許可のダイアログを表示する
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func selectedLocation(location: CLLocation) {
        selectedCurrentPrefecture(location: location)
    }

    func deleteLocation() {

    }
    
    private func selectedCurrentPrefecture(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            requestLocation()
        } else if status == .denied || status == .restricted {
            authorizationHandler?(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completionHandler?(locations)
        locationManager.stopUpdatingLocation()

        guard let location = locations.first else { return }
        selectedLocation(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorHandler?(error)
        locationManager.stopUpdatingLocation()
    }
}
