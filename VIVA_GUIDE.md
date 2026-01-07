# WeatherDashboard - Viva & Demonstration Guide

## Pre-Demonstration Checklist

### Before Your Viva:
- [ ] API key inserted and tested
- [ ] App builds without errors or warnings
- [ ] App runs successfully on simulator/device
- [ ] At least 3-4 locations saved for demonstration
- [ ] Familiar with all code sections
- [ ] Reviewed SwiftData relationship implementation
- [ ] Understand async/await networking flow
- [ ] Can explain MVVM architecture
- [ ] AI Declaration PDF prepared

## Demonstration Flow (Suggested 10-15 minutes)

### 1. Launch & Default Behavior (2 minutes)
**Show:**
- App launches with London automatically loaded
- Point out the four tabs
- Briefly show each tab's gradient background

**Explain:**
- "The app launches with London as the default location"
- "Data is loaded asynchronously using async/await"
- "All tabs share the same ViewModel for data consistency"

### 2. Search & Sync (3 minutes)
**Show:**
- Search for a new location (e.g., "Paris")
- Wait for loading indicator
- Point out confirmation alert
- Switch between tabs showing synced data

**Explain:**
- "Geocoding converts place name to coordinates using CLGeocoder"
- "Weather fetched from OpenWeather One Call API 3.0"
- "5 POIs discovered using MKLocalSearch for tourist attractions"
- "Data saved to SwiftData with Place → AnnotationModel relationship"
- "All tabs update simultaneously via @Published properties"

### 3. Now Tab - Current Weather (2 minutes)
**Show:**
- Current temperature display
- Weather advisory card with color-coded icon
- Detailed weather information

**Explain:**
- "Advisory generated using WeatherAdviceCategory enum"
- "Temperature-based logic determines advice and icon"
- "Gradient background for visual consistency"

### 4. Forecast Tab - 8-Day Weather (2 minutes)
**Show:**
- Bar chart with highs and lows
- Scroll through daily forecast cards
- Date formatting

**Explain:**
- "SwiftUI Charts framework for the bar chart"
- "Shows 8 days of forecast data"
- "Color-coded: orange for highs, blue for lows"
- "DateFormatterUtils for readable dates"

### 5. Map Tab - POI Interactions (3 minutes)
**Show:**
- Interactive map with 5 POI pins
- Tap a pin → zooms to 500m
- Long press a pin → opens Google search
- Tap POI in list → map centers
- Long press list item → Google search

**Explain:**
- "MapKit integration with custom annotations"
- "5 POIs found via MKLocalSearch"
- "Multiple interaction patterns: tap vs long press"
- "Smooth zoom animation using withAnimation"

### 6. Stored Places Tab (2 minutes)
**Show:**
- List of saved locations
- Tap a place → loads and switches to Now tab
- Long press → Google search
- Swipe to delete

**Explain:**
- "SwiftData persistence with @Query"
- "Cascade delete removes Place and associated POIs"
- "lastUsedAt timestamp for sorting"
- "Multiple gestures: tap, long press, swipe"

### 7. Revisit & Error Handling (1 minute)
**Show:**
- Search for an already-saved location
- Point out "loaded from storage" alert
- (Optional) Search invalid location to show error handling

**Explain:**
- "Revisiting reuses stored POIs, only refreshes weather"
- "Efficient: reduces API calls"
- "Invalid locations trigger alert and revert to London"

## Code Explanation - Key Sections to Know

### 1. Data Models (Place.swift)
**Be ready to explain:**
```swift
@Relationship(deleteRule: .cascade, inverse: \AnnotationModel.place)
var annotations: [AnnotationModel] = []
```
- SwiftData relationship with cascade delete
- One-to-many: Place has many AnnotationModels
- Inverse relationship for bidirectional navigation

### 2. WeatherService (WeatherService.swift)
**Be ready to explain:**
- URLComponents for safe URL construction
- Query parameters for One Call API 3.0
- async/await with try/await pattern
- Custom error handling with WeatherMapError
- JSON decoding with date strategy

### 3. LocationManager (LocationManager.swift)
**Be ready to explain:**
- CLGeocoder for geocoding
- MKLocalSearch.Request for POI discovery
- naturalLanguageQuery: "Tourist Attractions"
- Error handling for failed geocoding
- Array transformation: MKMapItem → AnnotationModel

### 4. MainAppViewModel (MainAppViewModel.swift)
**Be ready to explain:**
- @MainActor for UI updates
- @Published properties for view binding
- loadLocation(byName:) flow:
  1. Check if exists
  2. Geocode
  3. Fetch weather (fail-fast)
  4. Find POIs
  5. Create Place with relationships
  6. Save to SwiftData
  7. Update UI state
- Difference between loadLocation(byName:) and loadLocation(fromPlace:)

### 5. Views
**Be ready to explain:**
- @EnvironmentObject for ViewModel injection
- Gradient backgrounds: LinearGradient
- Loading states with ProgressView
- Chart implementation in ForecastView
- Map annotations in MapView
- Gesture recognizers: onTapGesture, onLongPressGesture
- List interactions and .onDelete modifier

## Conceptual Questions to Prepare For

### SwiftData
- Q: "Why use SwiftData over Core Data?"
- A: "SwiftData is Apple's modern persistence framework with simpler syntax, better SwiftUI integration, and automatic relationship management using macros like @Model and @Relationship."

- Q: "How do relationships work in SwiftData?"
- A: "The @Relationship macro defines connections between models. Cascade delete ensures child entities (POIs) are removed when parent (Place) is deleted. Inverse creates bidirectional links."

### Networking
- Q: "Why use async/await instead of completion handlers?"
- A: "Async/await provides cleaner, more readable code, better error handling, and avoids callback hell. It's Swift's modern concurrency approach."

- Q: "How do you handle network errors?"
- A: "Custom WeatherMapError enum conforming to LocalizedError provides specific error cases (invalidURL, networkError, decodingError, etc.) with user-friendly descriptions."

### Architecture
- Q: "Why MVVM?"
- A: "MVVM separates concerns: Views handle UI, ViewModel manages business logic and state, Models represent data. This makes code testable, maintainable, and follows SwiftUI best practices."

- Q: "How do you synchronize data across tabs?"
- A: "Single source of truth in MainAppViewModel using @Published properties. All views observe the same ViewModel via @EnvironmentObject, so changes propagate automatically."

### MapKit
- Q: "How do you find POIs?"
- A: "MKLocalSearch.Request with naturalLanguageQuery 'Tourist Attractions' searches within a region. Results are filtered, transformed to AnnotationModels, and limited to 5."

- Q: "What's the 500m zoom?"
- A: "Setting MKCoordinateSpan to 0.005 degrees (~500m) provides a close-up view when tapping a POI pin. The exact distance varies by latitude."

### API Compliance
- Q: "Why not use third-party libraries?"
- A: "Coursework requirements restrict to native frameworks only. This demonstrates understanding of Apple's APIs and prevents over-reliance on external dependencies."

- Q: "How do you stay within API rate limits?"
- A: "Explicit search submit (no auto-search), reuse stored POIs on revisit, and timestamp tracking (lastWeatherFetchedAt) for potential future rate limiting logic."

## Common Mistakes to Avoid

1. **Don't say "I don't know"**
   - Instead: "I'd need to review that section, but my understanding is..."

2. **Don't blame the template**
   - Take ownership of the implementation
   - Explain your decisions

3. **Don't just read code**
   - Explain the purpose and flow
   - Connect to requirements

4. **Don't rush**
   - Speak clearly and at a steady pace
   - Wait for questions to be fully asked

5. **Don't forget error cases**
   - Be ready to show error handling
   - Explain recovery strategies

## Enhancement Justifications (If Added)

If you added enhancements (15% marks), prepare to justify:

### Example: Unit Toggle (Imperial/Metric)
- **What**: Button to switch between Celsius and Fahrenheit
- **Why**: Improves UX for international users
- **How**: Adds @Published var for unit preference, persists to UserDefaults, converts temps in views
- **Value**: User customization, demonstrates state management

### Example: Pull-to-Refresh
- **What**: Swipe down in Now tab to refresh weather
- **Why**: Gives users control over data freshness
- **How**: .refreshable modifier on ScrollView, calls loadLocation
- **Value**: Improved UX, follows iOS conventions

### Example: Weather Animations
- **What**: Custom weather condition animations (without Lottie)
- **Why**: Enhances visual appeal and user engagement
- **How**: SwiftUI animation modifiers, conditional views based on weather
- **Value**: Polish, demonstrates SwiftUI animation skills

## Time Management

- **Opening (1 min)**: Brief overview of app purpose
- **Core Demo (10 min)**: Show all required features
- **Code Walk (5 min)**: Explain 2-3 key sections in detail
- **Q&A (5-10 min)**: Answer conceptual and technical questions
- **Closing (1 min)**: Summary of achievements

## Final Tips

1. **Practice the demo** multiple times before the viva
2. **Have backup plans** if network fails (use screenshots/video)
3. **Be enthusiastic** about your work
4. **Connect features to requirements** explicitly
5. **Admit and learn from mistakes** if bugs appear
6. **Prepare questions** to ask at the end (shows engagement)

## Checklist: Ready for Viva?

- [ ] Can launch and demo app smoothly
- [ ] Can explain SwiftData relationships
- [ ] Can explain networking flow with async/await
- [ ] Can explain MVVM architecture
- [ ] Can walk through MainAppViewModel methods
- [ ] Can explain Map interactions implementation
- [ ] Can justify any enhancements made
- [ ] Have AI Declaration PDF ready
- [ ] Know how to answer conceptual questions
- [ ] Practiced the full demo at least 3 times

---

**Confidence Builder**: You've implemented a fully functional, requirement-compliant iOS app using only native frameworks. You understand SwiftUI, SwiftData, async networking, and MapKit. You're ready!

**Good luck with your viva! 🍀**
