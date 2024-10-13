//
//  WeatherHeaderView.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//


import Foundation
import SwiftUI

struct WeatherHeader: View {
    @Binding private(set) var city: String
    @ObservedObject private(set) var viewModel: WeatherViewModel
    
    var showAlert: (String) -> Void // Add showAlert closure here
    
    var body: some View {
        VStack(spacing: 15) {
            // App heading
            HStack {
                Text("US National Forecast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Search bar
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(height: 35)
                
                TextField("Search for another city", text: $city, onCommit: {
                    Task {
                        await viewModel.fetchWeather(for: city, showAlert: showAlert)
                        city = "" // Clear search field after fetching
                    }
                })
                .padding(.horizontal, 16)
            }
        }
    }
}
