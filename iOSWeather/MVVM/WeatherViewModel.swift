//
//  WeatherViewModel.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published private(set) var currentLocationWeather: Weather?
    @Published private(set) var otherWeatherCards: [Weather] = []
    @Published private(set) var iconURLs: [String: String] = [:]
    
    private var addedCities = Set<String>()
    private let networkService: NetworkService // Injected NetworkService
    private let geocodingService: GeocodingService // Injected GeocodingService
    private let cacheService: WeatherCacheService // Injected WeatherCacheService
    private let locationService: LocationService // Injected LocationSerice
    private let apiKey = "9c5792eccc075cfabe6e4ad738bc1bbe"
    private let userDefaultsKey = "SavedWeatherCards"
    
    // Initialize with NetworkService, GeocodingService, WeatherCacheService and LocationSerice dependencies
    init(networkService: NetworkService = NetworkManager(),
         geocodingService: GeocodingService = GeocodingActorService(),
         cacheService: WeatherCacheService = DefaultWeatherCacheService(),
         locationService: LocationService = DefaultLocationService()) {
        
        self.networkService = networkService
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.cacheService = cacheService
        loadWeatherCards()
    }
    
    // Save weather cards to UserDefaults
    private func saveWeatherCards() {
        cacheService.saveWeatherCards(otherWeatherCards, iconURLs: iconURLs)
    }
    
    // Save weather cards to UserDefaults
    private func loadWeatherCards() {
        let (savedWeatherCards, savedIconURLs) = cacheService.loadWeatherCards()
        otherWeatherCards = savedWeatherCards
        iconURLs = savedIconURLs
        for weather in savedWeatherCards {
            addedCities.insert(weather.name.lowercased())
        }
    }
    
    // Delete weather card and update cache
    func deleteWeatherCard(at offsets: IndexSet) {
        for index in offsets {
            let weatherToDelete = otherWeatherCards[index]
            addedCities.remove(weatherToDelete.name.lowercased())
            cacheService.deleteWeatherCard(weatherToDelete, from: &otherWeatherCards)
        }
    }
    
    // Fetch weather for the current location
    func fetchWeatherForCurrentLocation(showAlert: @escaping (String) -> Void) async {
        do {
            let location = try await locationService.fetchCurrentLocation()
            await fetchWeatherCo(lat: location.coordinate.latitude, lon: location.coordinate.longitude, isCurrentLocation: true)
            
        } catch let error as LocationError {
            showAlert(error.localizedDescription)
        } catch {
            showAlert("An unknown error occurred. Please try again.")
        }
    }
    
    // Fetch weather for a given city with async/await
    func fetchWeather(for city: String, showAlert: @escaping (String) -> Void) async {
        do {
            let placemarks = try await geocodingService.geocodeCity(city)
            if let placemark = placemarks.first, let location = placemark.location {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                guard let countryCode = placemark.isoCountryCode, countryCode == "US" else {
                    showAlert("Only U.S. cities are allowed.")
                    return
                }
                
                guard let locality = placemark.locality else {
                    showAlert("Please enter a U.S. city instead of U.S. state")
                    return
                }
                
                if addedCities.contains(locality.lowercased()) {
                    showAlert("City \(locality) is already added.")
                    return
                }
                
                await fetchWeatherCo(lat: lat, lon: lon, isCurrentLocation: false)
            }
        } catch {
            showAlert("Failed to get location for the entered city.")
        }
    }
    
    // Fetch weather by latitude and longitude using async/await and NetworkService
    func fetchWeatherCo(lat: Double, lon: Double, isCurrentLocation: Bool) async {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let weather: Weather = try await networkService.fetchData(from: url)
            
            // Add this print statement to inspect the decoded weather data
            print("\n Decoded Weather Data: \(weather)")
            
            if isCurrentLocation {
                self.currentLocationWeather = weather
            } else {
                guard !addedCities.contains(weather.name.lowercased()) else {
                    return
                }
                self.otherWeatherCards.append(weather)
                addedCities.insert(weather.name.lowercased())
                saveWeatherCards()
            }
            
            if let iconCode = weather.weather.first?.icon {
                let iconURL = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
                if isCurrentLocation {
                    self.iconURLs["current"] = iconURL
                } else {
                    self.iconURLs[weather.name] = iconURL
                }
                saveWeatherCards()
            }
        } catch {
            print("Error fetching weather data: \(error.localizedDescription)")
        }
    }
}
