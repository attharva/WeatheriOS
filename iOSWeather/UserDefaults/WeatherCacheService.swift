//
//  WeatherCacheService.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import Foundation

protocol WeatherCacheService {
    func saveWeatherCards(_ weatherCards: [Weather], iconURLs: [String: String])
    func loadWeatherCards() -> (weatherCards: [Weather], iconURLs: [String: String])
    func deleteWeatherCard(_ weather: Weather, from weatherCards: inout [Weather])
}

class DefaultWeatherCacheService: WeatherCacheService {
    
    private let weatherCardsKey = "SavedWeatherCards"
    private let iconURLsKey = "SavedIconURLs"
    
    // Save weather cards and icon URLs to UserDefaults
    func saveWeatherCards(_ weatherCards: [Weather], iconURLs: [String: String]) {
        let encoder = JSONEncoder()
        if let encodedWeather = try? encoder.encode(weatherCards) {
            UserDefaults.standard.set(encodedWeather, forKey: weatherCardsKey)
        }
        UserDefaults.standard.set(iconURLs, forKey: iconURLsKey)
    }
    
    // Load weather cards and icon URLs from UserDefaults
    func loadWeatherCards() -> (weatherCards: [Weather], iconURLs: [String: String]) {
        let decoder = JSONDecoder()
        var weatherCards: [Weather] = []
        var iconURLs: [String: String] = [:]
        
        if let savedData = UserDefaults.standard.data(forKey: weatherCardsKey),
           let decodedWeather = try? decoder.decode([Weather].self, from: savedData) {
            weatherCards = decodedWeather
        }
        
        if let savedIconURLs = UserDefaults.standard.dictionary(forKey: iconURLsKey) as? [String: String] {
            iconURLs = savedIconURLs
        }
        
        return (weatherCards, iconURLs)
    }
    
    // Delete a weather card from the array and save the updated list
    func deleteWeatherCard(_ weather: Weather, from weatherCards: inout [Weather]) {
        weatherCards.removeAll { $0.name == weather.name }
        saveWeatherCards(weatherCards, iconURLs: [:]) // Save the updated weather cards
    }
}
