//
//  WeatherDetailView.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 12/10/24.
//

import SwiftUI

struct WeatherDetailView: View {
    let weather: Weather
    let iconImage: UIImage? // Pass the cached image directly
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Main Weather Card with 3D Glass Effect
                    ZStack {
                        let sunrise = weather.sys?.sunrise ?? 0
                        let sunset = weather.sys?.sunset ?? 0
                        let isDayTime = Date().isDayTime(sunrise: sunrise, sunset: sunset)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(gradient: weather.getGradientBackground(isDayTime: isDayTime),
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                        
                        // Content of the card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(weather.name)
                                        .font(.system(size: 36, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .minimumScaleFactor(0.5)
                                    
                                    weather.getWeatherAnimation(isDayTime: isDayTime)
                                        .frame(height: 40)
                                }
                                Spacer()
                                
                                if let iconImage = iconImage {
                                    Image(uiImage: iconImage)
                                        .resizable()
                                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25) // Adjust size based on screen width
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                            }
                            
                            HStack {
                                Text("\(weather.main.temp, specifier: "%.1f")°C")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("Feels like \(String(format: "%.1f", weather.main.feelsLike))°C")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            
                            Text(weather.weather.first?.description.capitalized ?? "N/A")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("H: \(String(format: "%.1f", weather.main.tempMax))°C  L: \(String(format: "%.1f", weather.main.tempMin))°C")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    
                    VStack(spacing: 16) {
                        Text("Detailed Weather Information")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 10)
                        
                        // 2-column Grid using LazyVGrid
                        WeatherLazyVGrid(weather: weather)
                            .background(BlurView().cornerRadius(10)) // Apply blur to the entire grid
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .background(Color.clear)
                }
            }
            .navigationTitle("US National Forecast")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                handleOrientationChange(for: geometry.size)
            }
        }
    }
    
    // Handle layout changes for different screen sizes and orientations
    func handleOrientationChange(for size: CGSize) {
        if size.width > size.height {
            // Landscape
//            print("Landscape mode detected")
            // Adjust layout if needed for landscape
        } else {
            // Portrait
//            print("Portrait mode detected")
            // Adjust layout if needed for portrait
        }
    }
}




