//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData

// MARK: - Temperature Category
enum TempCategory: String, CaseIterable {
    case cold = "Cold"
    case cool = "Cool"
    case warm = "Warm"
    case hot = "Hot"

    var color: Color {
        switch self {
        case .cold: return .blue
        case .cool: return .cyan
        case .warm: return .orange
        case .hot: return .red
        }
    }

    static func from(tempC: Double) -> TempCategory {
        if tempC <= 10 { return .cold }
        else if tempC <= 20 { return .cool }
        else if tempC <= 28 { return .warm }
        else { return .hot }
    }
}

// MARK: - Temperature Data Model
private struct TempData: Identifiable {
    let id = UUID()
    let day: String
    let type: String
    let value: Double
    let category: TempCategory
}

// MARK: - Forecast View
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel

    private var chartData: [TempData] {
        vm.forecast.enumerated().flatMap { index, daily in
            let dayLabel = DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(daily.dt))
            return [
                TempData(
                    day: dayLabel,
                    type: "High",
                    value: daily.temp.max,
                    category: .from(tempC: daily.temp.max)
                ),
                TempData(
                    day: dayLabel,
                    type: "Low",
                    value: daily.temp.min,
                    category: .from(tempC: daily.temp.min)
                )
            ]
        }
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.6), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Loading forecast...")
                    .foregroundColor(.white)
            } else if !vm.forecast.isEmpty {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("8-Day Weather Forecast")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Chart
                        Chart(chartData) { item in
                            BarMark(
                                x: .value("Day", item.day),
                                y: .value("Temperature", item.value)
                            )
                            .foregroundStyle(by: .value("Type", item.type))
                        }
                        .frame(height: 250)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .chartForegroundStyleScale([
                            "High": Color.orange,
                            "Low": Color.blue
                        ])
                        
                        // Scrollable forecast list
                        VStack(spacing: 10) {
                            Text("Daily Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(Array(vm.forecast.enumerated()), id: \.offset) { index, daily in
                                ForecastDayCard(daily: daily)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    Text("No forecast data available")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ForecastDayCard: View {
    let daily: Daily
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(daily.dt)))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(daily.summary)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                VStack {
                    Image(systemName: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(Int(daily.temp.max))°")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Image(systemName: "arrow.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(Int(daily.temp.min))°")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
