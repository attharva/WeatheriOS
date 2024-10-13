//
//  WeatherDetailComponents.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import SwiftUI

struct GridRowView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.body)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 8)
    }
}

// Reusable Blur View for Glass Effect
struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

// LazyVGrid with custom columns setup
struct WeatherLazyVGrid: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    let weather: Weather
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
            GridRowView(icon: "thermometer", label: "Min Temp", value: "\(formatTemperature(weather.main.tempMin))°C")
            GridRowView(icon: "thermometer", label: "Max Temp", value: "\(formatTemperature(weather.main.tempMax))°C")
            GridRowView(icon: "thermometer.sun.fill", label: "Feels Like", value: "\(formatTemperature(weather.main.feelsLike))°C")
            GridRowView(icon: "wind", label: "Wind Speed", value: "\(formatWindSpeed(weather.wind?.speed ?? 0.0)) m/s")
            if let gust = weather.wind?.gust {
                GridRowView(icon: "tornado", label: "Wind Gust", value: "\(gust) m/s")
            }
            GridRowView(icon: "gauge", label: "Pressure", value: "\(weather.main.pressure) hPa")
            GridRowView(icon: "humidity.fill", label: "Humidity", value: "\(weather.main.humidity)%")
            GridRowView(icon: "eye", label: "Visibility", value: "\((weather.visibility ?? 0) / 1000) km")
            if let seaLevel = weather.main.seaLevel {
                GridRowView(icon: "waveform", label: "Sea Level", value: "\(seaLevel) hPa")
            }
            if let groundLevel = weather.main.grndLevel {
                GridRowView(icon: "arrow.down", label: "Ground Level", value: "\(groundLevel) hPa")
            }
            GridRowView(icon: "sunrise.fill", label: "Sunrise", value: "\(convertUnixTimeToReadableFormat(weather.sys?.sunrise ?? 0))")
            GridRowView(icon: "sunset.fill", label: "Sunset", value: "\(convertUnixTimeToReadableFormat(weather.sys?.sunset ?? 0))")
//            if let country = weather.sys?.country { GridRowView(icon: "flag", label: "Country", value: country) }
        }
    }
}

