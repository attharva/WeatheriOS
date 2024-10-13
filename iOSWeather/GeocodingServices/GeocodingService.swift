//
//  GeocodingService.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import CoreLocation
import Foundation

protocol GeocodingService {
    func geocodeCity(_ city: String) async throws -> [CLPlacemark]
}

actor GeocodingActorService: GeocodingService {
    private let geocoder = CLGeocoder() // Geocoder instance can be shared within the actor
    
    func geocodeCity(_ city: String) async throws -> [CLPlacemark] {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(city) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: placemarks ?? [])
                }
            }
        }
    }
}

