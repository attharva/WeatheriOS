//
//  iOSWeatherTests.swift
//  iOSWeatherTests
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import XCTest
import CoreLocation
@testable import iOSWeather

@MainActor  // Ensure the test is run on the main actor because WeatherViewModel is isolated to the main actor.
final class WeatherViewModelTests: XCTestCase {
    
    func testIsLocationServiceEnabled() {
        // Arrange
        let isLocationServiceEnabled = true
        
        // Act & Assert
        XCTAssertTrue(isLocationServiceEnabled, "Location service should be enabled for this test to pass.")
    }
    
    
    func testFetchWeatherForCurrentLocation_Success() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.locationToReturn = CLLocation(latitude: 40.7128, longitude: -74.0060) // New York City
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService) // Inject the mock
        
        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Retrieve the currentLocationWeather value
        let currentWeather = viewModel.currentLocationWeather
        
        // Assert
        XCTAssertNil(alertMessage, "No alert message should be shown on success.")
        XCTAssertNotNil(currentWeather, "The weather should be updated for the current location.")
    }
    
    func testFetchWeatherForCurrentLocation_ServicesDisabled() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.errorToThrow = .servicesDisabled
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService)
        
        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Assert
        XCTAssertEqual(alertMessage, LocationError.servicesDisabled.localizedDescription, "Should show services disabled message.")
    }
    
    func testFetchWeatherForCurrentLocation_Restricted() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.errorToThrow = .restricted
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService)
        
        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Assert
        XCTAssertEqual(alertMessage, LocationError.restricted.localizedDescription, "Should show restricted message.")
    }
    
    func testFetchWeatherForCurrentLocation_FetchFailed() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.errorToThrow = .locationFetchFailed
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService)

        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Assert
        XCTAssertEqual(alertMessage, LocationError.locationFetchFailed.localizedDescription, "Should show location fetch failed message.")
    }
    
    func testFetchWeatherForCurrentLocation_NoLocationReturned() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.locationToReturn = nil
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService)
        
        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Assert
        XCTAssertEqual(alertMessage, LocationError.locationFetchFailed.localizedDescription, "Should show location fetch failed message when no location is returned.")
    }
    
    
    
    func testFetchWeatherForCurrentLocation_PermissionDenied() async throws {
        // Arrange
        let mockLocationService = MockLocationService()
        mockLocationService.errorToThrow = .permissionDenied
        
        let viewModel = WeatherViewModel(networkService: NetworkManager(),
                                         geocodingService: GeocodingActorService(),
                                         cacheService: DefaultWeatherCacheService(),
                                         locationService: mockLocationService)
        
        var alertMessage: String?
        
        // Act
        await viewModel.fetchWeatherForCurrentLocation { message in
            alertMessage = message
        }
        
        // Assert
        XCTAssertEqual(alertMessage, LocationError.permissionDenied.localizedDescription, "Should show permission denied message.")
    }
}



final class NetworkServiceTests: XCTestCase {
    
    func testFetchWeatherData_Success() async throws {
        // Arrange
        let mockNetworkService = MockNetworkService()
        
        // Act
        let weather: Weather = try await mockNetworkService.fetchData(from: URL(string: "https://mockurl.com")!)
        
        // Assert
        XCTAssertEqual(weather.name, "New York", "The city name should be New York.")
        XCTAssertEqual(weather.main.temp, 15.5, "The temperature should be 15.5°C.")
        XCTAssertEqual(weather.weather.first?.main, "Clouds", "The weather should be Clouds.")
    }

    
    func testFetchWeatherData_Failure() async throws {
        // Arrange
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(URLError(.badServerResponse))
        
        // Act & Assert
        do {
            let _: Weather = try await mockNetworkService.fetchData(from: URL(string: "https://mockurl.com")!)
            XCTFail("The network call should fail with a bad server response error.")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse, "Should return bad server response error.")
        }
    }
    
    func testFetchWeatherData_StatusCodeError() async throws {
        // Arrange
        let mockNetworkService = MockNetworkService()
        
        // Simulate a 404 error response
        mockNetworkService.result = .failure(URLError(.badServerResponse))
        
        // Act & Assert
        do {
            _ = try await mockNetworkService.fetchData(from: URL(string: "https://mockurl.com")!) as Weather
            XCTFail("The fetchData method should throw an error for a bad server response")
        } catch {
            XCTAssertTrue(error is URLError, "The error should be a URLError.")
        }
    }
}

import MapKit

@MainActor
final class GeocodingServiceTests: XCTestCase {
    
    func testGeocodeCity_Success() async throws {
         // Arrange
         let mockGeocodingService = MockGeocodingService()
         let expectedPlacemark = mockGeocodingService.createMockPlacemark()  // Use the mock placemark
         
         mockGeocodingService.placemarksToReturn = [expectedPlacemark]
         
         // Act
         let placemarks = try await mockGeocodingService.geocodeCity("New York")
         
         // Assert
         XCTAssertEqual(placemarks.count, 1, "Should return one placemark")
         XCTAssertEqual(placemarks.first, expectedPlacemark, "Returned placemark should match expected placemark")
     }
    
    func testGeocodeCity_NoResults() async throws {
        // Arrange
        let mockGeocodingService = MockGeocodingService()
        mockGeocodingService.placemarksToReturn = []
        
        // Act
        let placemarks = try await mockGeocodingService.geocodeCity("Unknown City")
        
        // Assert
        XCTAssertEqual(placemarks.count, 0, "Should return no placemarks for unknown city")
    }
    
    func testGeocodeCity_Failure() async throws {
        // Arrange
        let mockGeocodingService = MockGeocodingService()
        mockGeocodingService.errorToThrow = URLError(.cannotFindHost) // Simulating a network error
        
        // Act & Assert
        do {
            _ = try await mockGeocodingService.geocodeCity("New York")
            XCTFail("The geocoding method should have thrown an error")
        } catch {
            XCTAssertTrue(error is URLError, "Error should be of type URLError")
        }
    }
}



