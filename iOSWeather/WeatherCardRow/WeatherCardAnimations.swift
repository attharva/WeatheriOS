//
//  WeatherCardAnimations.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import Foundation
import SwiftUI

struct MovingEmojiView: View {
    let emoji: String
    @State private var offset: CGFloat = -10 // Initial position offscreen
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 25)) // Adjust size as per design
            .offset(x: offset, y: 0) // Move along the x-axis
            .onAppear {
                // Animate the emoji movement from left to right
                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: true)) {
                    offset = 10 // Move the emoji back and forth
                }
            }
    }
}

struct TwinklingEmojiView: View {
    let emoji: String
    @State private var opacities: [Double] = Array(repeating: 1.0, count: 3) // Opacity for 3 emojis
    
    var body: some View {
        HStack(spacing: 8) { 
            ForEach(0..<3, id: \.self) { index in
                ZStack {
                    Text(emoji)
                        .font(.system(size: 15))
                        .frame(width: 30, height: 30)
                        .opacity(opacities[index]) // Apply different opacities for each emoji
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: Double.random(in: 0.5...1.5)).repeatForever(autoreverses: true)) {
                                opacities[index] = 0.3 // Twinkling effect
                            }
                        }
                }
            }
        }
        .frame(width: 100) 
    }
}

