//
//  File.swift
//  
//
//  Created by kerik on 08.09.2024.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case denied, failedToLocate
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var completion: ((Result<CLLocation, LocationError>) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        self.completion = completion
        let status = CLLocationManager.authorizationStatus()

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            checkAuthorizationStatus(status)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        checkAuthorizationStatus(status)
    }

    // Метод для проверки статуса авторизации и запуска/остановки обновления координат
    private func checkAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            completion?(.failure(.denied))
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            completion?(.success(location))
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(.failedToLocate))
    }
}
