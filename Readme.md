# MovieBrowser – iOS Challenge  
### OPENLANE Technical Challenge Submission by *Agam Airi*

---

## 🎯 Project Overview

**MovieBrowser** is a modern SwiftUI app that lets you browse movies, view details with a poster-tinted header, discover recommendations, and manage favorites. It focuses on clean architecture, robust networking, responsive UI, and clear state handling.


### ✨ Key Features
- **Movie Browsing:** Grid/List layouts with adaptive posters  
- **Details + Recommendations:** Deep-link into recommended titles  
- **Favorites:** Like/unlike with local persistence  
- **Search:** Title/year search with live filtering  
- **Sorting & Filters:** A–Z, Z–A, Newest, Oldest, and **Rating (High→Low)** sort  
- **Pull-to-Refresh:** Manual refresh on list & grid  
- **Dark Mode Support:** Poster-tinted gradient adapts to color scheme  
- **Error/Empty States:** Friendly messaging with retry  

---

## 🏗️ Architecture & Design

### MVVM + Lightweight DI
- **Views** are declarative and lean.  
- **ViewModels** own async work, derive view state, and expose UI-ready values.  
- **Services** isolate networking, mapping, and caching.  
- **Dependency Injection** via a `ServiceLocator` injected in the SwiftUI environment.  


### Design Principles
- Single responsibility, clear boundaries  
- Protocol-first for testability (`MovieService`, `LikesProviding`)  
- Predictable **ViewState** (`idle/loading/loaded/empty/error`)  
- No force unwraps; safe URL building with `URLComponents`  

---

## 🛠️ Technical Implementation

### Core Technologies
- **SwiftUI** (iOS)  
- **Swift Concurrency (`async/await`)**  
- **XCTest** unit tests  

### API Integration
- **List:** `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/list.json`  
- **Details:** `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/{id}.json`  
- **Recommended:** `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/recommended/{id}.json`  

### 🌐 Networking
- `URLSessionAPIClient` with:  
  - `waitsForConnectivity`, sensible timeouts  
  - cache policy that revalidates when online  
- **Safe Endpoints:** `Endpoints` builds URLs with `URLComponents` (no `!`)  
- **Service Layer:** `MovieServiceImpl`  
  - Shared JSON decode with small **in-memory response cache** (`NSCache`)  
  - **Offline awareness:** maps transport errors → `.offline`  
  - Clear error mapping: `.http`, `.decoding`, `.offline`  
- **Images:** `ImageLoader`  
  - In-memory **decoded image cache** + **URLCache** for bytes  
  - Cache-first fetch (`.returnCacheDataElseLoad`)  
- **Poster Gradient:** `AverageColorProvider`  
  - Computes average color with Core Image to generate a header gradient  
  - Adapts palette for light/dark schemes  

### 💾 Persistence
- **Favorites:** `LikeStore` stores `Set<MovieID>` in **UserDefaults** (single key)  
- **Ratings for Sort:** On demand, details are fetched once and cached in the List VM  

### 🔍 Search & Sorting
- **Search:** Case-insensitive contains on **title** or **year**  
- **Sort:** A–Z, Z–A, Newest, Oldest, **Rating (High→Low)**  
  - Rating sort lazily prefetches details & caches rating values  

---

## 📱 User Experience

- **List/Grid toggle** from the navigation bar  
- **Filters Sheet** to change sort/layout  
- **Recommended Carousel** on details with deep navigation  
- **Pull-to-Refresh** on list & grid  
- **Error/Empty Views** with clear messaging and retry  

---

## 🧪 Testing Strategy

- **MovieServiceTests**  
  - Decoding & caching behavior  
  - HTTP error mapping  
  - Offline uses cached details  
- **MovieListViewModelTests**  
  - Non-empty list → `.loaded`  
- **LikeStoreTests**  
  - Toggle and lookup  

---

## 🚀 Environment

- **Xcode:** 16.4  
- **iOS:** 18.6  
- **Device/Simulator:** iPhone 16 Pro  
- **Language:** Swift 5+ with Swift Concurrency  

---

## 🧠 Trade-offs & Next Steps

**Why not a custom disk cache?**  
For a challenge-sized app, `URLCache` (disk/network bytes) + `NSCache` (decoded JSON/images) delivers great UX with minimal complexity. For a production offline-first app, I’d consider:

- Two-tier domain cache (disk-backed store with TTL)  
- On-disk image cache and prefetching  
- Snapshot/UI tests, more ViewModel coverage  
- SwiftData/Core Data for richer local models  
- Accessibility: Dynamic Type & high-contrast audits  

**API shape considerations:**  
Ratings only live in **details**, so rating sort performs a one-time details prefetch in the List VM. This keeps launch fast while enabling rating-based sorting when requested.  

---


## 🙏 Credits

- API: TradeRev iOS challenge repository  
- UI Inspiration: **Google Stitch** (as a design aid; all UI implemented in SwiftUI)  

---

## 📄 License

This code is provided for technical challenge review and learning purposes. Adapt as needed.



# BELOW IS THE INSTRUCTIONS AS IS: 

# The challenge
## Goal
Build a simple movie browser app using **Swift 5+** and **SwiftUI**.  
Load a list of movies, navigate to a details screen, show recommended movies, and support “likes”.
Functionality and code quality matter more than pixel perfection.

## Requirements
- **Language & UI:** Swift 5+, SwiftUI.
- **Concurrency:** Use Swift Concurrency (`async/await`).
- **Package Management:** Swift Package Manager.
- **Architecture:** MVVM or a similarly clean pattern.
- **Networking:** Handle loading, error, and empty states gracefully.
- **Environment:** In your README, specify the **Xcode version**, **iOS version**, and **device/simulator model** you used for testing.
- **Repo:** Fork this repo and keep your fork public until review.

## API
- **List:**  
  `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/list.json`  

- **Details:**  
  `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/{id}.json`  

- **Recommended:**  
  `https://raw.githubusercontent.com/TradeRev/tr-ios-challenge/master/details/recommended/{id}.json`  

## What to Build
- **Movie List:** fetch and display the list.
- **Details Screen:** show details for a movie and its recommendations.
- **Navigation:** tapping a recommended movie opens its details.
- **Likes:** allow marking a movie as liked/favorited and reflect this state across list and details (persist locally; your choice of method).

## Bonus
- Unit tests.
- Lightweight caching (e.g., images or responses).
- Dark Mode support.
- Brief README notes on trade-offs and “what you’d do next”.
