//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.openURL) var openURL
    @State private var selectedAnnotation: AnnotationModel?

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Loading map...")
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 0) {
                    // Map
                    Map(coordinateRegion: $vm.mapRegion, annotationItems: vm.pois) { poi in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        // Tap to zoom to 500m
                                        vm.focus(on: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude), zoom: 0.005)
                                    }
                                    .onLongPressGesture {
                                        // Long press to Google search
                                        if let encodedName = poi.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                           let url = URL(string: "https://www.google.com/search?q=\(encodedName)") {
                                            openURL(url)
                                        }
                                    }
                                
                                Text(poi.name)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .frame(height: 400)
                    .cornerRadius(15)
                    .padding()
                    
                    // POI List
                    if !vm.pois.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Points of Interest")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(vm.pois) { poi in
                                        POIRow(poi: poi) {
                                            // Tap to center map
                                            vm.focus(on: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude))
                                        } onLongPress: {
                                            // Long press to Google search
                                            if let encodedName = poi.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                               let url = URL(string: "https://www.google.com/search?q=\(encodedName)") {
                                                openURL(url)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding(.bottom)
                    } else {
                        Text("No points of interest available")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct POIRow: View {
    let poi: AnnotationModel
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle")
                .foregroundColor(.red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Lat: \(poi.latitude, specifier: "%.4f"), Lon: \(poi.longitude, specifier: "%.4f")")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            onLongPress()
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}
