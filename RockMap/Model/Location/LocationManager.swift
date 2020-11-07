//
//  LocationManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import CoreLocation
import Combine

final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    private override init() {}
    
    var isEnabledLocationServices: Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    var isAuthorized: Bool {
        return locationManager.authorizationStatus == .authorizedAlways
            || locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    var latitude: Double = .zero
    var longitude: Double = .zero
    var address = ""
    
    private var locationManager = CLLocationManager()
    private var bindings = Set<AnyCancellable>()
    
    /// パーミッション許可のダイアログを表示する
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        CLGeocoder.reverseGeocode(location: location)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { [weak self] address in
                
                guard let self = self else { return }
                
                self.address = address
            })
            .store(in: &bindings)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
}
