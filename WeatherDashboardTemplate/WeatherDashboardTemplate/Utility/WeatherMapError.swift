//  WeatherMapError.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
//
import Foundation

enum WeatherMapError: Error, LocalizedError, Identifiable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case geocodingFailed
    case invalidResponse
    case missingData(message: String)
    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Configuration Error: The URL is invalid or malformed"
        case .networkError(let error):
            return "A network connection error occurred: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse data from the server: \(error.localizedDescription)"
        case .geocodingFailed:
            return "Could not find coordinates for the location. Please try another name."
        case .invalidResponse:
            return "The server returned an error. Data is unavailable."
        case .missingData(let message):
            return "Missing or invalid data: \(message)"
        }
    }
}
