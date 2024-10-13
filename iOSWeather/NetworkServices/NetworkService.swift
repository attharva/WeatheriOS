//
//  NetworkService.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 11/10/24.
//

import Foundation

protocol NetworkService {
    func fetchData<T: Decodable>(from url: URL) async throws -> T
}

class NetworkManager: NetworkService {
    // Fetch weather data from URL
    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API response: \(jsonString)")
        }

        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}

