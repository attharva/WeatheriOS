//
//  MockLocationService.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import CoreLocation
import Foundation

class MockLocationService: LocationService {
    var locationToReturn: CLLocation?
    var errorToThrow: LocationError?
    
    func fetchCurrentLocation() async throws -> CLLocation {
        if let error = errorToThrow {
            throw error
        }
        if let location = locationToReturn {
            return location
        }
        throw LocationError.locationFetchFailed
    }
    
}
