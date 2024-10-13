//
//  WeatherCardRow.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import Foundation
import SwiftUI

struct WeatherCardRow: View {
    let weather: Weather
    let iconURL: String?
    let isCurrentLocation: Bool
    
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            let isDayTime = Date().isDayTime(
                sunrise: weather.sys?.sunrise ?? 0,
                sunset: weather.sys?.sunset ?? 0
            )
            let backgroundGradient = weather.getGradientBackground(isDayTime: isDayTime)

            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: backgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 10)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // City name
                        Text(isCurrentLocation ? "📍 \(weather.name)" : (weather.name))
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        weather.getWeatherAnimation(isDayTime: isDayTime)
                            .frame(height: 20)
                    }

                    Spacer()

                    // Weather icon from cache or download
                    if let iconURLString = iconURL, let url = URL(string: iconURLString) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 70, height: 70)
                                .aspectRatio(contentMode: .fit)
                        } else {
                            ProgressView()
                                .frame(width: 70, height: 70)
                                .task {
                                    do {
                                        if let fetchedImage = try await ImageCacheManager.shared.fetchImage(from: url) {
                                            self.image = fetchedImage
                                        }
                                    } catch {
                                        print("Error fetching image: \(error)")
                                    }
                                }
                        }
                    }
                }

                HStack {
                    // Temperature
                    Text("\(weather.main.temp, specifier: "%.1f")°C")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Feels like temperature
                    Text("Feels like \(String(format: "%.1f", weather.main.feelsLike))°C")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Text("H: \(String(format: "%.1f", weather.main.tempMax))°C  L: \(String(format: "%.1f", weather.main.tempMin))°C")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)

        }
        .contentShape(Rectangle())
        .background(
            NavigationLink(destination: WeatherDetailView(weather: weather, iconImage: image)) {
                EmptyView()
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 0, height: 0)
            .opacity(0)
        )
        .padding(.vertical, 5)
        .padding(.horizontal, 16)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .onAppear {
            loadImage()
        }
    }

    func loadImage() {
        guard let iconURL = iconURL, let url = URL(string: iconURL) else {
            isLoading = false
            return
        }
        
        Task {
            do {
                if let fetchedImage = try await ImageCacheManager.shared.fetchImage(from: url) {
                    self.image = fetchedImage
                }
            } catch {
                print("Error fetching image: \(error)")
            }
            isLoading = false
        }
    }
}
