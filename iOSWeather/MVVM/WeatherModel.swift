//
//  WeatherModel.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import Foundation

struct Weather: Codable {
    let name: String
    let main: Main
    let weather: [WeatherInfo]
    let wind: Wind?
    let sys: Sys?
    let clouds: Clouds?
    let visibility: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case main
        case weather
        case wind
        case sys
        case clouds
        case visibility
    }
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct WeatherInfo: Codable {
    let main: String
    let description: String
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case main
        case description
        case icon
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
    
    enum CodingKeys: String, CodingKey {
        case speed
        case deg
        case gust
    }
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case country
        case sunrise
        case sunset
    }
}

struct Clouds: Codable {
    let all: Int?
    
    enum CodingKeys: String, CodingKey {
        case all
    }
}
