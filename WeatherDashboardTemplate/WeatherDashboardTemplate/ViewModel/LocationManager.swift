//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit

// MARK: - Geocoding Response Models
struct GeocodingResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
    }
}

@MainActor
final class LocationManager {
    private let apiKey = "8xxxxxxxxxxxxxxxxxxxxx8"

    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        // Uses OpenWeather Geocoding API to convert a string address into geographic coordinates.
        // Extracts the name, latitude, and longitude from the first result.
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
        
        // Check if API key is still placeholder
        guard !apiKey.contains("xxx") else {
            throw WeatherMapError.missingData(message: "API key not configured. Please add your OpenWeather API key in LocationManager.swift")
        }
        
        guard var components = URLComponents(string: "http://api.openweathermap.org/geo/1.0/direct") else {
            throw WeatherMapError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: address),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw WeatherMapError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherMapError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw WeatherMapError.invalidResponse
            }
            
            let results = try JSONDecoder().decode([GeocodingResponse].self, from: data)
            
            guard let result = results.first else {
                throw WeatherMapError.geocodingFailed
            }
            
            // Use the full name with state/country if available for better display
            var displayName = result.name
            if let state = result.state {
                displayName += ", \(state)"
            }
            if let country = result.country {
                displayName += ", \(country)"
            }
            
            return (name: displayName, lat: result.lat, lon: result.lon)
        } catch let error as WeatherMapError {
            throw error
        } catch {
            throw WeatherMapError.geocodingFailed
        }
    }

    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        // Executes the search request.
        // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
        // Limits the final array size to the specified `limit`.
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist Attractions"
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: center, span: span)
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        let annotations = response.mapItems
            .compactMap { item -> AnnotationModel? in
                guard let name = item.name else { return nil }
                return AnnotationModel(
                    name: name,
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
            .prefix(limit)
        
        return Array(annotations)
    }
}
