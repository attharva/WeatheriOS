//
//  MockNetworkService.swift
//  iOSWeatherTests
//
//  Created by Atharva Kulkarni on 13/10/24.
//

import Foundation
@testable import iOSWeather

class MockNetworkService: NetworkService {
    var result: Result<Data, Error>?
    
    // Mock data - JSON representing the weather
    let weatherJSON = """
    {
        "name": "New York",
        "main": {
            "temp": 15.5,
            "feels_like": 14.0,
            "temp_min": 10.0,
            "temp_max": 20.0,
            "pressure": 1013,
            "humidity": 70
        },
        "weather": [
            {
                "main": "Clouds",
                "description": "overcast clouds",
                "icon": "04d"
            }
        ]
    }
    """
    
    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        guard let result = result else {
            // By default, decode the mock JSON to simulate a successful network response
            let data = Data(weatherJSON.utf8)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        case .failure(let error):
            throw error
        }
    }
}
