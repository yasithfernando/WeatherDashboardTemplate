//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""
    @Published var currentWeather: Current?
    @Published var forecast: [Daily] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
    private var isInitializing = false

    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()

    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()

    /// Use a context to manage database operations
    private let context: ModelContext

    init(context: ModelContext) {
        // Initialize the ModelContext and attempt to fetch previously visited places from SwiftData, sorted by most recent use.
        // If no visited places exist (first launch), load the default location.
        // Otherwise, load the most recently used place.
        self.context = context

        // Corrected FetchDescriptor to include sorting by 'lastUsedAt' in reverse order.
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }

        // First launch: no data → perform full London setup
        if visited.isEmpty {
            Task {
                isInitializing = true
                await loadDefaultLocation()
                isInitializing = false
            }
        } else if let mostRecent = visited.first {
            // Otherwise, load most recently used place
            Task {
                isInitializing = true
                await loadLocation(fromPlace: mostRecent)
                isInitializing = false
            }
        }
    }

    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        Task {
            do {
                // MARK: call loadLocation(byName:)
                try await loadLocation(byName: city)
                query = ""
            } catch {
                appError = .networkError(error)
            }
        }
    }
    func loadDefaultLocation() async {
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
        print("[MainAppViewModel] Loading default location: \(defaultPlaceName)")
        do {
            try await loadLocation(byName: defaultPlaceName)
            print("[MainAppViewModel] Default location loaded successfully")
        } catch {
            print("[MainAppViewModel] Failed to load default location: \(error)")
            // During initialization, just show error without reverting
            if isInitializing {
                appError = .missingData(message: "Failed to load default location. Please check your internet connection and try searching for a location.")
            } else {
                appError = .networkError(error)
            }
        }
    }

    func search() async throws {
        // If the query is not empty, calls `select(placeNamed:)` with the current query string.
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try await loadLocation(byName: trimmed)
    }

    /// Validate weather before saving a new place; create POI children once.
    func loadLocation(byName: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
        // 2. Otherwise, geocodes the fresh place name using `locationManager`.
        // 3. Fetches weather data using `weatherService` as a fail-fast check.
        // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
        // 5. Inserts the new `Place` into the `visited` array and saves the context.
        // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
        // 7. If any step fails, logs the error and reverts to the default location with an alert.
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let trimmed = byName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if place already exists
            if let existing = visited.first(where: { 
                $0.name.lowercased() == trimmed.lowercased() 
            }) {
                await loadLocation(fromPlace: existing)
                appError = .missingData(message: "Location loaded from storage.")
                return
            }
            
            // Geocode the address
            let (name, lat, lon) = try await locationManager.geocodeAddress(trimmed)
            
            // Fetch weather as fail-fast validation
            let weatherResponse = try await weatherService.fetchWeather(lat: lat, lon: lon)
            
            // Extract current weather and forecast
            self.currentWeather = weatherResponse.current
            self.forecast = Array(weatherResponse.daily.prefix(8))
            
            // Find POIs
            let annotations = try await locationManager.findPOIs(lat: lat, lon: lon, limit: 5)
            
            // Create new place
            let newPlace = Place(name: name, latitude: lat, longitude: lon)
            newPlace.lastWeatherFetchedAt = .now
            
            // Associate annotations with place
            for annotation in annotations {
                annotation.place = newPlace
                newPlace.annotations.append(annotation)
            }
            
            // Insert and save
            context.insert(newPlace)
            try context.save()
            
            // Update visited array
            visited.insert(newPlace, at: 0)
            
            // Update UI state
            self.pois = annotations
            self.activePlaceName = name
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            focus(on: coordinate)
            
            appError = .missingData(message: "Location '\(name)' added successfully!")
            
        } catch {
            // Only revert if not during initialization
            if !isInitializing {
                await revertToDefaultWithAlert(message: "Failed to load '\(byName)'. Reverting to \(defaultPlaceName).")
            } else {
                appError = .missingData(message: "Failed to load '\(byName)'. Please check the location name and your internet connection.")
            }
            throw error
        }
    }

    func loadLocation(fromPlace place: Place) async{
        // Sets loading state, then attempts to load all data for an existing `Place` object.
        // Updates the place's `lastUsedAt` and saves the context upon success.
        // Catches and sets `appError` for any failure during the load process.
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await loadAll(for: place)
            place.lastUsedAt = .now
            try context.save()
        } catch {
            appError = .networkError(error)
        }
    }

    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
        // Only revert if we're not already trying to load the default
        appError = .missingData(message: message)
        
        // Check if there's an existing valid place to fall back to
        if let fallback = visited.first, fallback.name.lowercased() != activePlaceName.lowercased() {
            await loadLocation(fromPlace: fallback)
        } else if !isInitializing {
            // Only try to load default if not already initializing
            do {
                try await loadLocation(byName: defaultPlaceName)
            } catch {
                // If default also fails, just show the error
                appError = .missingData(message: "Unable to load location. Please check your internet connection.")
            }
        }
    }

    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
        withAnimation {
            mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            )
        }
    }

    private func loadAll(for place: Place) async throws {
        // Sets `activePlaceName` and prints a loading message.
        // Always refreshes weather data from the API.
        // Checks if the `Place` object has existing annotations (POIs).
        // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
        // If annotations exist, uses the cached list for `self.pois`.
        // Calls `focus(on:zoom:)` to update the map view.
        // Ensures the place is at the top of the `visited` list (if not already).
        
        activePlaceName = place.name
        print("Loading data for \(place.name)...")
        
        // Always refresh weather
        let weatherResponse = try await weatherService.fetchWeather(lat: place.latitude, lon: place.longitude)
        
        self.currentWeather = weatherResponse.current
        self.forecast = Array(weatherResponse.daily.prefix(8))
        
        place.lastWeatherFetchedAt = .now
        
        // Handle POIs
        if place.annotations.isEmpty {
            let newAnnotations = try await locationManager.findPOIs(lat: place.latitude, lon: place.longitude, limit: 5)
            
            for annotation in newAnnotations {
                annotation.place = place
                place.annotations.append(annotation)
            }
            
            try context.save()
            self.pois = newAnnotations
        } else {
            self.pois = place.annotations
        }
        
        // Focus map
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        focus(on: coordinate)
        
        // Move to top of visited list
        if let index = visited.firstIndex(where: { $0.id == place.id }), index != 0 {
            visited.remove(at: index)
            visited.insert(place, at: 0)
        }
    }

    func delete(place: Place) {
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        // Attempts to save the context.
        
        context.delete(place)
        visited.removeAll { $0.id == place.id }
        
        do {
            try context.save()
        } catch {
            appError = .networkError(error)
        }
    }

}
