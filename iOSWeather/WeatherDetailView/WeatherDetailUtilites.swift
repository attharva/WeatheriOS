//
//  WeatherDetailUtilites.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import Foundation
import SwiftUI

func formatTemperature(_ temp: Double) -> String {
    return String(format: "%.1f", temp)
}

func formatWindSpeed(_ speed: Double) -> String {
    return String(format: "%.1f", speed)
}

func convertUnixTimeToReadableFormat(_ timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
