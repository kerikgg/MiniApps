//
//  File.swift
//  
//
//  Created by kerik on 08.09.2024.
//

import Foundation

enum NetworkingError: Error {
    case badURL, decodingError, badResponse
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    let decoder = JSONDecoder()

    func fetchData(latitude: Double, longitude: Double) async throws -> WeatherModel {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m"

        guard let url = URL(string: urlString) else {
            throw NetworkingError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingError.badResponse
        }

        do {
            let weatherModel = try decoder.decode(WeatherModel.self, from: data)
            return weatherModel
        } catch {
            throw NetworkingError.decodingError
        }
    }
}
