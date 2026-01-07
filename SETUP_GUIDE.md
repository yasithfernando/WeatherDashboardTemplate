# WeatherDashboard - Quick Setup Guide

## Prerequisites
- macOS with Xcode 15.0 or later
- iOS 17.0+ simulator or device
- OpenWeather API key (free tier)

## Setup Steps

### 1. Get Your OpenWeather API Key

1. Visit https://openweathermap.org/api
2. Sign up for a free account
3. Navigate to API Keys section
4. Copy your API key (looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)
5. Note: It may take a few hours for new keys to activate

### 2. Configure the API Key

1. Open the project in Xcode
2. Navigate to: `WeatherDashboardTemplate/ViewModel/WeatherService.swift`
3. Find line 11: `private let apiKey = "8xxxxxxxxxxxxxxxxxxxxx8"`
4. Replace with your actual API key: `private let apiKey = "YOUR_ACTUAL_API_KEY_HERE"`
5. Navigate to: `WeatherDashboardTemplate/ViewModel/LocationManager.swift`
6. Find line 26: `private let apiKey = "8xxxxxxxxxxxxxxxxxxxxx8"`
7. Replace with your actual API key: `private let apiKey = "YOUR_ACTUAL_API_KEY_HERE"`
8. **Important**: Use the SAME API key in both files!
9. Save both files (⌘S)

### 3. Build and Run

```bash
# Open the project
open WeatherDashboardTemplate/WeatherDashboardTemplate.xcodeproj

# Or from Xcode:
# File → Open → Select WeatherDashboardTemplate.xcodeproj
# Select iPhone simulator (iPhone 15 Pro recommended)
# Press ⌘R to build and run
```

## First Launch

When the app launches for the first time:
1. It will automatically load **London** as the default location
2. Wait a few seconds for weather data and POIs to load
3. You'll see a confirmation alert when data is loaded

## Usage Guide

### Search for a Location
1. Type a city name in the search bar at the top
2. Press Enter or tap the search icon
3. Wait for weather and POI data to load
4. Confirmation alert will appear

### Navigate Tabs
- **Now**: Current weather with advisory
- **Forecast**: 8-day forecast with bar chart
- **Map**: Interactive map with 5 tourist POIs
- **Saved**: List of all stored locations

### Map Interactions
- **Tap a pin**: Zoom to 500m view
- **Long press a pin**: Search on Google
- **Tap a POI in the list**: Center map on that POI
- **Long press list item**: Search on Google

### Stored Places Interactions
- **Tap a place**: Load weather and switch to Now tab
- **Long press a place**: Search location on Google
- **Swipe left**: Delete the place permanently

## Troubleshooting

### "No weather data available"
- Check your API key is correct
- Verify internet connection
- Wait a few hours if API key is newly created
- Check API quota (free tier: 1000 calls/day)

### "Could not find coordinates"
- Try a more specific location name (e.g., "Paris, France" instead of "Paris")
- Check spelling
- Try a major city name first to test

### No POIs appearing on map
- Some locations may not have tourist attractions nearby
- Try major tourist cities (London, Paris, Rome, Tokyo)
- POI search uses a 0.05 degree radius

### App crashes on launch
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Delete app from simulator/device
- Rebuild and run

### Build errors
- Ensure you're targeting iOS 17.0 or later
- Check Xcode version is 15.0+
- Verify all files are included in the target

## Testing Checklist

Test these features before submission:

- [ ] App launches with London weather
- [ ] Search for your city works
- [ ] See 5 POIs on the map
- [ ] Bar chart shows 8 days of forecast
- [ ] Advisory message displays correctly
- [ ] Can tap POI pins to zoom
- [ ] Long press opens Google search
- [ ] Swipe to delete in Saved tab works
- [ ] Tapping saved place switches to Now tab
- [ ] Data persists after closing and reopening app
- [ ] Invalid location shows error and reverts to London

## Recommended Test Locations

These cities have good tourist POI coverage:
- London, UK (default)
- Paris, France
- Rome, Italy
- Tokyo, Japan
- New York, USA
- Sydney, Australia
- Barcelona, Spain
- Dubai, UAE

## API Rate Limiting

Free tier limits: 1000 calls/day

Each search makes:
- 1 geocoding call (free)
- 1 weather API call (counted)
- 1 POI search call (free)

Tips to stay under limit:
- Don't repeatedly search the same location
- Revisiting stored locations only makes 1 weather call
- Use the Saved tab to switch between places

## Performance Tips

- Keep number of stored places reasonable (< 20)
- Delete unused locations regularly
- On slower networks, wait for loading indicators

## Support Resources

- OpenWeather API Docs: https://openweathermap.org/api/one-call-3
- SwiftUI Documentation: https://developer.apple.com/documentation/swiftui
- SwiftData Guide: https://developer.apple.com/documentation/swiftdata
- Apple HIG: https://developer.apple.com/design/human-interface-guidelines

## Contact

For coursework-related questions, contact your instructor or refer to the coursework specification document.

---

**Last Updated**: January 8, 2026  
**Version**: 1.0  
**Compatible**: iOS 17.0+, Xcode 15.0+
