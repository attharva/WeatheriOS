//
//  WeatherUtilities.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import Foundation
import SwiftUI

// Utility to determine if it's day or night based on sunrise and sunset times
extension Date {
    func isDayTime(sunrise: Int, sunset: Int) -> Bool {
        let currentTime = Int(self.timeIntervalSince1970)
        return currentTime >= sunrise && currentTime <= sunset
    }
}

// Utility to get gradient background based on weather condition and time of day
extension Weather {
    func getGradientBackground(isDayTime: Bool) -> Gradient {
        let weatherCondition = self.weather.first?.main ?? "Clear"
        
        switch weatherCondition {
        case "Clear":
            return isDayTime ? Gradient(colors: [Color.blue.opacity(0.8), Color.yellow.opacity(0.2)]) :
            Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.6)])
        case "Clouds":
            return isDayTime ? Gradient(colors: [Color.gray.opacity(0.7), Color.white.opacity(0.3)]) :
            Gradient(colors: [Color.black.opacity(0.7), Color.gray.opacity(0.5)])
        case "Rain", "Drizzle":
            return Gradient(colors: [Color.blue.opacity(0.5), Color.gray.opacity(0.3)])
        case "Thunderstorm":
            return Gradient(colors: [Color.purple.opacity(0.8), Color.black.opacity(0.6)])
        case "Snow":
            return Gradient(colors: [Color.white.opacity(0.9), Color.blue.opacity(0.5)])
        case "Mist", "Fog", "Haze":
            return Gradient(colors: [Color.gray.opacity(0.5), Color.white.opacity(0.3)])
        case "Smoke":
            return isDayTime ? Gradient(colors: [Color.gray.opacity(0.7), Color.black.opacity(0.3)]) :
            Gradient(colors: [Color.gray.opacity(0.9), Color.black.opacity(0.6)])
        default:
            return isDayTime ? Gradient(colors: [Color.blue.opacity(0.5), Color.white.opacity(0.3)]) :
            Gradient(colors: [Color.black.opacity(0.8), Color.gray.opacity(0.6)])
        }
    }
    
    func getWeatherAnimation(isDayTime: Bool) -> AnyView {
        let weatherCondition = self.weather.first?.main ?? "Clear"
        
        switch weatherCondition {
        case "Clear":
            return AnyView(TwinklingEmojiView(emoji: isDayTime ? "☀️" : "✨"))
        case "Clouds":
            return AnyView(MovingEmojiView(emoji: "☁️"))
        case "Rain", "Drizzle":
            return AnyView(MovingEmojiView(emoji: "🌧"))
        case "Thunderstorm":
            return AnyView(TwinklingEmojiView(emoji: "⚡️"))
        case "Snow":
            return AnyView(TwinklingEmojiView(emoji: "❄️"))
        case "Mist", "Fog", "Haze":
            return AnyView(MovingEmojiView(emoji: "🌬️"))
        case "Smoke":
            return AnyView(MovingEmojiView(emoji: "💨"))
        default:
            return AnyView(MovingEmojiView(emoji: isDayTime ? "🌞" : "🌙"))
        }
    }
}


