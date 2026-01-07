//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Loading weather...")
                    .foregroundColor(.white)
            } else if let current = vm.currentWeather, let weather = current.weather.first {
                ScrollView {
                    VStack(spacing: 20) {
                        // Location name
                        Text(vm.activePlaceName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        // Temperature
                        Text("\(Int(current.temp))°C")
                            .font(.system(size: 72, weight: .thin))
                            .foregroundColor(.white)
                        
                        // Weather icon and description
                        VStack(spacing: 10) {
                            Image(systemName: iconName(for: weather.description))
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text(weather.description.capitalized)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        // Advisory card
                        let category = WeatherAdviceCategory.from(temp: current.temp, description: weather.description)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: category.icon)
                                    .font(.title)
                                    .foregroundColor(category.color)
                                
                                Text(category.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text(category.adviceText)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Weather details
                        VStack(spacing: 15) {
                            Text("Weather Details")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 10) {
                                WeatherDetailRow(label: "Feels Like", value: "\(Int(current.feelsLike))°C")
                                WeatherDetailRow(label: "Humidity", value: "\(current.humidity)%")
                                WeatherDetailRow(label: "Wind Speed", value: "\(current.windSpeed) m/s")
                                WeatherDetailRow(label: "Pressure", value: "\(current.pressure) hPa")
                                WeatherDetailRow(label: "UV Index", value: "\(current.uvi)")
                                WeatherDetailRow(label: "Clouds", value: "\(current.clouds)%")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "cloud.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    Text("No weather data available")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func iconName(for description: String) -> String {
        let lower = description.lowercased()
        if lower.contains("clear") { return "sun.max.fill" }
        else if lower.contains("cloud") { return "cloud.fill" }
        else if lower.contains("rain") { return "cloud.rain.fill" }
        else if lower.contains("snow") { return "snowflake" }
        else if lower.contains("thunder") { return "cloud.bolt.fill" }
        else { return "cloud.sun.fill" }
    }
}

struct WeatherDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}
