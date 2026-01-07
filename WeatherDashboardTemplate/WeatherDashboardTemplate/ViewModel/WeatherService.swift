//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
@MainActor
final class WeatherService {
    private let apiKey = "8xxxxxxxxxxxxxxxxxxxxx8"

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        // Performs an asynchronous network request using URLSession.
        // Validates the HTTP response status code.
        // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
        // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.
        
        // Check if API key is still placeholder
        guard !apiKey.contains("xxx") else {
            throw WeatherMapError.missingData(message: "API key not configured. Please add your OpenWeather API key in WeatherService.swift")
        }
        
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall") else {
            throw WeatherMapError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "exclude", value: "minutely,hourly,alerts"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw WeatherMapError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherMapError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherMapError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            throw WeatherMapError.decodingError(error)
        }
    }
}
