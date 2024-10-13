//
//  LocationService.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import CoreLocation
import Foundation

protocol LocationService {
    func fetchCurrentLocation() async throws -> CLLocation
}

// Location Errors
enum LocationError: Error, LocalizedError {
    case servicesDisabled
    case permissionDenied
    case restricted
    case locationFetchFailed
    
    var errorDescription: String? {
        switch self {
        case .servicesDisabled:
            return "Location services are disabled. Please enable them in Settings."
        case .permissionDenied:
            return "Location permissions are denied. Please allow location access in Settings."
        case .restricted:
            return "Location access is restricted. Please check your parental control or device settings."
        case .locationFetchFailed:
            return "Unable to fetch current location. Please try again."
        }
    }
}

class DefaultLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func fetchCurrentLocation() async throws -> CLLocation {
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }
        
        // Check authorization status and request permission if needed
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Request permission
        case .denied:
            throw LocationError.permissionDenied
        case .restricted:
            throw LocationError.restricted
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            throw LocationError.locationFetchFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.locationContinuation = continuation
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationContinuation?.resume(returning: location)
            locationContinuation = nil // Reset continuation after resuming
            locationManager.stopUpdatingLocation()
        }
    }

    // CLLocationManagerDelegate method to handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.locationFetchFailed)
        locationContinuation = nil // Reset continuation after resuming
    }
}
