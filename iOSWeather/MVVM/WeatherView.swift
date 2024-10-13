//
//  WeatherView.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State private var city: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                WeatherHeader(city: $city, viewModel: viewModel, showAlert: { message in
                    alertMessage = message
                    showAlert = true
                })
                .padding(.horizontal, 16)

                List {
                    if let currentWeather = viewModel.currentLocationWeather {
                        WeatherCardRow(
                            weather: currentWeather,
                            iconURL: viewModel.iconURLs["current"],
                            isCurrentLocation: true
                        )
                        .padding(.vertical, 8)
                    }

                    ForEach(viewModel.otherWeatherCards, id: \.name) { weather in
                        WeatherCardRow(
                            weather: weather,
                            iconURL: viewModel.iconURLs[weather.name],
                            isCurrentLocation: false
                        )
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: viewModel.deleteWeatherCard)
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Weather Forecast", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle()) 
        }
        .task {
            await viewModel.fetchWeatherForCurrentLocation(showAlert: { message in
                alertMessage = message
                showAlert = true
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
