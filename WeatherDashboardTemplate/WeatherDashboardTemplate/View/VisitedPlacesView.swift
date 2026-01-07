//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Stored Places")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                if vm.visited.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        Text("No saved locations yet")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Search for a location to get started")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(vm.visited) { place in
                            PlaceRow(place: place)
                                .listRowBackground(Color.white.opacity(0.2))
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    // Tap to load and switch to Now tab
                                    Task {
                                        await vm.loadLocation(fromPlace: place)
                                        vm.selectedTab = 0
                                    }
                                }
                                .onLongPressGesture {
                                    // Long press to Google search
                                    if let encodedName = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                       let url = URL(string: "https://www.google.com/search?q=\(encodedName)") {
                                        openURL(url)
                                    }
                                }
                        }
                        .onDelete(perform: deletePlace)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
    }
    
    private func deletePlace(at offsets: IndexSet) {
        for index in offsets {
            let place = vm.visited[index]
            vm.delete(place: place)
        }
    }
}

struct PlaceRow: View {
    let place: Place
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 15) {
                    Label {
                        Text("\(place.latitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    } icon: {
                        Image(systemName: "location.circle")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Label {
                        Text("\(place.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    } icon: {
                        Image(systemName: "globe")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Text("Last visited: \(place.lastUsedAt, style: .relative) ago")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
