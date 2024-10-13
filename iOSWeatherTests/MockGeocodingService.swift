//
//  MockGeocodingService.swift
//  iOSWeatherTests
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import CoreLocation
import Foundation
import MapKit
@testable import iOSWeather

class MockGeocodingService: GeocodingService {
    var placemarksToReturn: [CLPlacemark]?
    var errorToThrow: Error?
    
    func geocodeCity(_ city: String) async throws -> [CLPlacemark] {
        if let error = errorToThrow {
            throw error
        }
        return placemarksToReturn ?? []
    }
    
    // Function to create a mock CLPlacemark
    func createMockPlacemark() -> CLPlacemark {
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let addressDictionary: [String: Any] = ["City": "New York", "State": "NY", "Country": "USA"]
        
        let mockPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        return mockPlacemark
    }
}


