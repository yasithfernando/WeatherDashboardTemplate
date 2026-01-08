//
//  NavBarView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
//

import SwiftUI
import SwiftData

struct NavBarView: View {
    @EnvironmentObject var vm: MainAppViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 🔍 Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "location.magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.body)
                    
                    TextField("Search location...", text: $vm.query)
                        .foregroundColor(.white)
                        .tint(.white)
                        .submitLabel(.search)
                        .onSubmit { vm.submitQuery() }
                    
                    if !vm.query.isEmpty {
                        Button {
                            vm.query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                
                Button {
                    vm.submitQuery()
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // 🌤 Tabs
            TabView(selection: $vm.selectedTab) {
                CurrentWeatherView()
                    .tabItem { Label("Now", systemImage: "sun.max.fill") }
                    .tag(0)

                ForecastView()
                    .tabItem { Label("Forecast", systemImage: "calendar") }
                    .tag(1)

                MapView()
                    .tabItem { Label("Map", systemImage: "map") }
                    .tag(2)

                VisitedPlacesView()
                    .tabItem { Label("Saved", systemImage: "globe") }
                    .tag(3)
            }
            .accentColor(.blue)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)

        .overlay {
            if vm.isLoading {
                ProgressView("Loading…")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .alert(item: $vm.appError) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}



#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}

//#Preview("Full Dashboard") {
//    // 👇 This creates a mock ModelContext using your in-memory preview container
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//
//    // 👇 This displays *all* your tab content at once
//    NavBarView()
//        .environmentObject(vm)
//}
//