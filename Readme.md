# MovieBrowser - iOS Challenge
### OpenLane Technical Challenge Submission by Laurent Lefebvre

---

## 🎯 Project Overview

MovieBrowser is a modern, feature-rich iOS application built with **SwiftUI** that showcases best practices in iOS development. The app provides an intuitive interface for browsing movies, viewing detailed information, discovering recommendations, and managing personal favorites.

### ✨ Key Features
- **Beautiful Movie Browsing**: Grid-based layout with high-quality movie posters
- **Detailed Movie Information**: Comprehensive details including ratings, descriptions, and release dates
- **Smart Recommendations**: Discover related movies with seamless navigation
- **Favorites System**: Like/unlike movies with persistent local storage
- **Professional Search**: Fuzzy matching, typo tolerance, and intelligent suggestions
- **Responsive Design**: Optimized for all iPhone sizes with adaptive layouts
- **Dark Mode**: Full support for light and dark appearance modes
- **Accessibility**: VoiceOver support with semantic labels
- **Visual Polish**: Custom loading states and error handling

---

## 🏗️ Architecture & Design

### MVVM Architecture
The app follows a clean **Model-View-ViewModel (MVVM)** pattern with proper separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Views       │    │   ViewModels    │    │     Models      │
│                 │    │                 │    │                 │
│ • MovieListView │◄──►│ • MovieListVM   │◄──►│ • Movie         │
│ • MovieDetailV  │    │ • MovieDetailVM │    │ • MovieDetail   │
│ • Components    │    │ • LoadingState  │    │ • APIResponse   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │    Services     │
                       │                 │
                       │ • NetworkService│
                       │ • LikesService  │
                       │ • SearchService │
                       └─────────────────┘
```

### Key Design Principles
- **Single Responsibility**: Each component has one clear purpose
- **Dependency Injection**: Services are injected for better testability
- **Protocol-Oriented Programming**: Extensive use of protocols for flexibility
- **Reactive Programming**: Combine framework for state management
- **Error Handling**: Comprehensive error states with user-friendly messages
- **Performance**: Lazy loading, caching, and memory optimization

---

## 🛠️ Technical Implementation

### Core Technologies
- **Swift 6.1.2**: Latest Swift features and best practices
- **SwiftUI**: Declarative UI framework with modern design patterns
- **Async/Await**: Modern concurrency for network operations
- **Combine**: Reactive programming for state management and debouncing
- **Swift Package Manager**: Native dependency management
- **XCTest**: Comprehensive unit test coverage

### API Integration
The app integrates with the TradeRev movie API:
- **Movie List**: `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/list.json`
- **Movie Details**: `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/{id}.json`
- **Recommendations**: `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/recommended/{id}.json`

### Advanced Features

#### 🌐 Network Layer
- **Async/Await**: Modern concurrency patterns throughout
- **Error Handling**: Comprehensive error types with user-friendly messages
- **Caching**: Intelligent response caching for better performance
- **Retry Logic**: Automatic retry mechanisms for failed requests

#### 🎨 Design System
- **Consistent Styling**: Centralized design tokens for colors, typography, and spacing
- **Dark Mode**: Adaptive colors that work in both light and dark modes
- **Accessibility**: Full VoiceOver support and Dynamic Type compatibility
- **Animations**: Smooth, purposeful animations that enhance user experience

#### 💾 Data Persistence
- **UserDefaults**: Lightweight storage for user preferences and favorites
- **Image Caching**: Advanced image loading and caching with Kingfisher
- **State Persistence**: Maintains user's liked movies across app launches

#### 🔍 Search & Filtering
- **Professional Search System**: Fuzzy matching with typo tolerance
- **Real-time Suggestions**: Instant autocomplete as user types
- **Debounced Search**: Optimized search with 300ms debouncing
- **Multi-field Search**: Search by movie name, year, and other fields
- **Relevance Scoring**: Results ranked by match quality

---

## 📱 User Experience

### Intuitive Navigation
- **Sheet Presentations**: Modal detail views for focused content
- **Smooth Transitions**: Consistent navigation patterns throughout
- **Keyboard Management**: Intelligent keyboard dismissal

### Performance Optimizations
- **Lazy Loading**: Images and content load on-demand with shimmer effects
- **Memory Management**: Efficient image caching with Kingfisher
- **Smooth Scrolling**: Optimized list performance with LazyVGrid
- **Background Loading**: Non-blocking network operations with async/await

### Error Handling
- **User-Friendly Messages**: Clear, actionable error messages
- **Retry Mechanisms**: Easy retry options for failed operations
- **Graceful Degradation**: App remains functional even with network issues
- **Loading States**: Clear feedback during async operations

---

## 🧪 Testing Strategy

### Comprehensive Test Coverage
The app includes extensive unit tests covering:

#### Network Layer Tests
- ✅ Successful API responses and JSON parsing
- ✅ Network error handling and timeout scenarios
- ✅ Cache functionality and validation

#### ViewModel Tests
- ✅ State management and loading states
- ✅ Search functionality and debouncing
- ✅ Like/unlike operations and synchronization
- ✅ Error state handling and recovery

#### Service Tests
- ✅ Likes persistence and UserDefaults integration
- ✅ Data synchronization across screens
- ✅ Publisher behavior and Combine integration

#### Search Tests
- ✅ **Exact Matching**: Perfect string matches with highest relevance
- ✅ **Fuzzy Matching**: Typo tolerance with Levenshtein distance (e.g., "drk" → "dark")
- ✅ **Prefix/Contains**: Partial word matching scenarios
- ✅ **Case Insensitive**: Various capitalization scenarios
- ✅ **Year Search**: Numeric field matching capabilities
- ✅ **Debounce Testing**: Verifies 300ms search debouncing behavior
- ✅ **Suggestions**: Autocomplete functionality and edge cases
- ✅ **Performance**: Search performance with large datasets

---

## 🚀 Development Environment

### Dependencies
This project uses Swift Package Manager for dependency management:

- **[Kingfisher](https://github.com/onevcat/Kingfisher)** `~8.5.0`
  - High-performance image downloading and caching library
  - Provides superior memory management and disk caching
  - Includes retry logic and fade-in animations for better UX

### Development Environment
- **Xcode Version**: 16.4
- **Swift Version**: 6.1.2 (Language Mode: Swift 5)
- **iOS Deployment Target**: 16.0
- **Test Device**: iPhone 16 Pro Simulator

---

## 📊 Project Structure

```
MovieBrowser/
├── MovieBrowser/
│   ├── Models/
│   │   └── Movie.swift                    # Data models with JSON decoding
│   ├── Services/
│   │   ├── NetworkService.swift           # API communication layer
│   │   ├── LikesService.swift            # Local persistence for favorites
│   │   └── SimpleSearchService.swift     # Professional search implementation
│   ├── ViewModels/
│   │   ├── MovieListViewModel.swift      # List screen business logic
│   │   └── MovieDetailViewModel.swift    # Detail screen business logic
│   ├── Views/
│   │   ├── MovieListView.swift           # Main movie list interface
│   │   └── MovieDetailView.swift         # Movie detail interface
│   ├── Components/
│   │   ├── MovieCardView.swift           # Reusable movie card component
│   │   ├── SimpleAsyncImageView.swift    # Enhanced image loading component
│   │   └── SearchBarView.swift           # Search interface component
│   ├── Design/
│   │   └── DesignSystem.swift            # Design tokens and styling
│   ├── ContentView.swift                 # Root view
│   └── MovieBrowserApp.swift             # App entry point
├── MovieBrowserTests/
│   ├── NetworkServiceTests.swift         # Network layer tests
│   ├── MovieListViewModelTests.swift     # ViewModel tests
│   ├── LikesServiceTests.swift           # Persistence tests
│   ├── SimpleSearchServiceTests.swift    # Search functionality tests
│   └── MockServices.swift                # Test mocks and utilities
└── README.md                             # This documentation
```

---

## 🎨 Design Highlights

### Visual Design
- **Modern iOS Aesthetic**: Follows Apple's Human Interface Guidelines
- **Consistent Typography**: San Francisco font family with proper hierarchy
- **Color Harmony**: Carefully chosen color palette supporting light/dark modes
- **Spacing System**: 8pt grid system for consistent layouts
- **Card-based Layout**: Clean, scannable content organization

### Interaction Design
- **Loading States**: Custom shimmer effects for image loading placeholders
- **Error Recovery**: Intuitive retry mechanisms for failed operations
- **Keyboard Handling**: Smart keyboard dismissal throughout the app
- **Visual Feedback**: Clear loading and error states with appropriate messaging

### Accessibility
- **VoiceOver Support**: Accessibility labels added to key interactive elements
- **Semantic Structure**: Proper use of SwiftUI's built-in accessibility features
- **Touch Targets**: Interactive elements designed with appropriate sizing
- **Clear Visual Hierarchy**: Consistent typography and spacing for readability

---

## 🔄 Search Capabilities

The app features a **professional search system** designed for interview demonstration:

### 🔍 **Search Features**
- ✅ **Exact Matching**: Perfect string matches with highest relevance
- ✅ **Prefix Matching**: Finds movies starting with search terms
- ✅ **Contains Matching**: Searches within movie titles
- ✅ **Fuzzy Matching**: Handles typos with Levenshtein distance algorithm
- ✅ **Year Search**: Search movies by release year
- ✅ **Case Insensitive**: Works regardless of capitalization
- ✅ **Word-based Search**: Matches individual words in titles
- ✅ **Relevance Scoring**: Results ranked by match quality

### 💡 **User Experience Features**
- ✅ **Smart Suggestions**: Autocomplete based on available movies
- ✅ **Debounced Search**: 300ms debouncing to optimize performance
- ✅ **Immediate Suggestions**: Autocomplete responds instantly
- ✅ **Performance Optimized**: Fast search even with large collections
- ✅ **Clean Interface**: Intuitive search bar with clear results

---

## 🏆 Challenge Requirements Compliance

### ✅ Mandatory Requirements
- [x] **Language & UI**: Swift 5+ with SwiftUI ✨
- [x] **Concurrency**: Swift Concurrency (async/await) throughout ✨
- [x] **Package Management**: Swift Package Manager with Kingfisher ✨
- [x] **Architecture**: Clean MVVM pattern with proper separation ✨
- [x] **Networking**: Comprehensive error handling for all states ✨
- [x] **Repository**: Forked public repository ✨

### ✅ Core Features
- [x] **Movie List**: Beautiful grid layout with search functionality ✨
- [x] **Details Screen**: Rich movie information with recommendations ✨
- [x] **Navigation**: Smooth transitions between screens ✨
- [x] **Likes System**: Persistent favorites with visual feedback ✨

### ✅ Bonus Features (All Implemented!)
- [x] **Unit Tests**: Comprehensive test suite covering core functionality ✨
- [x] **Image Caching**: Advanced image loading with Kingfisher ✨
- [x] **Dark Mode**: Full light/dark mode support ✨
- [x] **Accessibility**: VoiceOver labels and semantic structure implementation ✨
- [x] **Performance**: Optimized for smooth scrolling experience ✨
- [x] **Error Recovery**: User-friendly error handling with retry options ✨

---

## 📈 Performance & Quality

### App Performance
- **Network Efficiency**: Response caching reduces redundant API calls
- **Smooth Scrolling**: Optimized list performance with lazy loading
- **Image Loading**: Progressive loading with shimmer placeholders and error handling

### Code Quality
- **Test Coverage**: Comprehensive unit test suite covering core functionality
- **Architecture**: Clean separation of concerns with MVVM pattern
- **Documentation**: Comprehensive inline documentation throughout
- **Code Style**: Consistent Swift style guide adherence
- **Error Handling**: Robust error handling with user-friendly recovery options

---

## 🔄 Trade-offs & Future Enhancements

### Current Implementation Trade-offs

#### **1. Search Implementation**
- **Current**: Client-side search with fuzzy matching for interview demonstration
- **Trade-off**: Works well for small datasets but would need server-side search for larger catalogs
- **Future Enhancement**: Implement server-side search with pagination and advanced filtering

#### **2. Local Storage**
- **Current**: UserDefaults for favorites persistence (simple and effective)
- **Trade-off**: No cross-device synchronization
- **Future Enhancement**: CloudKit integration for syncing favorites across devices

#### **3. Image Caching**
- **Current**: Kingfisher with default settings
- **Trade-off**: Basic cache management without custom policies
- **Future Enhancement**: Custom cache expiration policies and offline image storage

#### **4. Accessibility**
- **Current**: Basic accessibility labels on key interactive elements
- **Trade-off**: Limited to essential VoiceOver support
- **Future Enhancement**: Complete accessibility audit including:
  - Full VoiceOver navigation support
  - Dynamic Type implementation for all text elements
  - High contrast mode optimization
  - Voice Control compatibility
  - Switch Control support

### Potential Future Features

#### **Enhanced User Experience**
- **Advanced Animations**: Spring-based transitions and micro-interactions
- **Haptic Feedback**: Tactile responses for key user actions
- **Pull-to-Refresh**: Manual refresh capability for movie lists
- **Infinite Scrolling**: Load more movies as user scrolls

#### **Advanced Functionality**
- **Offline Mode**: Core Data implementation for offline movie browsing
- **Advanced Search Filters**: Filter by genre, rating range, decade, director
- **User Profiles**: Personal movie collections and viewing history
- **Social Features**: Share favorite movies and reviews with friends
- **Watch Lists**: Create and manage custom movie collections
- **Movie Ratings**: Allow users to rate movies they've watched

#### **Platform Expansion**
- **iPad Support**: Adaptive layouts optimized for larger screens
- **Apple Watch**: Quick access to favorites and movie lookup
- **macOS**: Catalyst app for desktop experience
- **tvOS**: Apple TV app for big screen browsing

#### **Technical Enhancements**
- **Push Notifications**: New movie recommendations and updates
- **Siri Integration**: Voice commands for movie search and favorites
- **Shortcuts Support**: Custom Siri Shortcuts for common actions
- **Widget Support**: Home screen widgets showing favorite movies
- **Background App Refresh**: Update movie data in background

#### **Analytics & Performance**
- **User Analytics**: Track usage patterns for better UX decisions
- **Performance Monitoring**: Real-time performance metrics and crash reporting
- **A/B Testing**: Test different UI variations for optimization
- **Advanced Caching**: Predictive caching based on user behavior

### Architecture Considerations

#### **Scalability Improvements**
- **Coordinator Pattern**: Enhanced navigation management for complex flows
- **Dependency Container**: More sophisticated dependency injection
- **Feature Modules**: Modular architecture for better code organization
- **Core Data**: Replace UserDefaults with robust local database

#### **Code Quality Enhancements**
- **SwiftLint Integration**: Automated code style enforcement
- **Continuous Integration**: Automated testing and deployment pipeline
- **Code Coverage Goals**: Achieve and maintain >90% test coverage
- **Documentation**: Generate and maintain API documentation

---

## 👨‍💻 About the Developer

**Laurent Lefebvre** - iOS Developer passionate about creating exceptional user experiences through clean code and thoughtful design.

### Contact
- **GitHub**: [ldlefebvre](https://github.com/ldlefebvre)
- **LinkedIn**: [Laurent Lefebvre](https://www.linkedin.com/in/laurentlefebvre/)

---

## 📄 License

This project is part of a technical challenge submission for OpenLane. The code demonstrates iOS development best practices and is available for review and evaluation purposes.

---

*Built with ❤️ and attention to detail for the OpenLane team*
