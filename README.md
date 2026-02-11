# 📱 Smart Session Recovery System

<div align="center">

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-2.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A robust iOS application architecture designed to automatically persist and restore user state—including navigation history, form data, and scroll positions—in the event of an app crash or forced termination.

[Features](#-features) • [Installation](#-installation) • [Testing](#-testing) • [Architecture](#-architecture) • [Requirements](#-requirements)

</div>

---

## ✨ Features

### 🧭 Crash-Proof Navigation
Automatically restores the exact screen the user was viewing using SwiftUI's `NavigationStack` with persistent path tracking.

### 📝 Intelligent Form Persistence
- Saves text inputs and toggles in real-time as the user types
- Uses `Combine` debouncing to optimize performance
- No data loss even during unexpected crashes

### 📜 Scroll Position Restoration
- Remembers the exact scroll position in lists
- Seamlessly restores the user's place when the app relaunches
- Custom visibility tracking for accurate position detection

### 💾 Codable State Management
- Single source of truth using JSON serialization
- Stored securely in the app's documents directory
- Lightweight and performant

---

## 🚀 Installation

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0+ deployment target
- Swift 5.7+

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart-session-recovery.git
   cd smart-session-recovery
   ```

2. **Open in Xcode**
   ```bash
   open SmartSessionRecovery.xcodeproj
   ```

3. **Project Structure**
   Copy the following files into your project:
   - `SessionManager.swift` - Core state management
   - `ViewHelpers.swift` - UI helper utilities
   - `Screens.swift` - Screen definitions
   - `SmartRecoveryApp.swift` - App entry point

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

---

## 🧪 Testing the Recovery System

Since iOS apps rarely exit normally, you must simulate a crash or process termination to properly test the recovery features.

### Testing Workflow

#### Step 1: Launch the App
Run the app in the Simulator or on a physical device via Xcode.

#### Step 2: Create User State
Choose one of these scenarios:

**Scenario A - Form Data:**
1. Navigate to the **Form Screen**
2. Type text in the "Bio" field
3. Toggle any switches

**Scenario B - Scroll Position:**
1. Navigate to the **Scroll List**
2. Scroll down to Item #45 or beyond
3. Let the app settle for a moment

#### Step 3: Simulate a Crash
⚠️ **Important:** Do NOT press the Home button (this only suspends the app)

**DO THIS:** Press the **Stop (■) button** in Xcode's toolbar

This instantly terminates the app process, simulating a real crash.

#### Step 4: Relaunch
Press the **Play (▶) button** in Xcode again.

#### Step 5: Verify Recovery
✅ The app should:
- Skip the Home screen
- Navigate directly to your last viewed screen
- Restore your typed text (Form scenario)
- Restore your scroll position (List scenario)

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────┐
│          SmartRecoveryApp               │
│  (App Entry Point + ContentView)        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│        SessionManager                    │
│  • State persistence (@Published)        │
│  • Debounced auto-save                   │
│  • JSON serialization                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         NavigationStack                  │
│  • Data-driven navigation                │
│  • Path restoration                      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│           Screen Views                   │
│  • HomeView                              │
│  • SmartFormView                         │
│  • SmartListView                         │
└─────────────────────────────────────────┘
```

### Core Components

#### 1. SessionManager (`SessionManager.swift`)

The brain of the system. Manages all state persistence logic.

**Key Features:**
- **Debounced Auto-Save:** Uses Combine's `.debounce` operator to prevent excessive disk writes
  ```swift
  $state
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .sink { [weak self] state in
          self?.saveState()
      }
  ```
  
- **Why Debouncing?** Waits until the user stops typing/scrolling for 0.5 seconds before saving. This balances data safety with performance.

#### 2. Navigation System (`NavigationStack`)

Uses iOS 16's modern data-driven navigation approach.

**Traditional vs. Smart Navigation:**

```swift
// ❌ Traditional (state is lost on crash)
NavigationLink(destination: DetailView()) {
    Text("Go to Detail")
}

// ✅ Smart Recovery (state is preserved)
NavigationStack(path: $session.state.navigationPath) {
    // Path is automatically restored from JSON
}
```

**How it works:**
- Navigation path is stored as an array of enums: `[AppRoute]`
- On app launch, the array is restored from JSON
- SwiftUI automatically rebuilds the view hierarchy

#### 3. Scroll Position Tracking (`ViewHelpers.swift`)

SwiftUI doesn't provide direct access to scroll offset, so we use a clever workaround:

**Tracking:**
```swift
// Attach to every list row
.onAppear { tracker = index }
```
As rows appear on screen, we update `lastScrollIndex`.

**Restoration:**
```swift
// On view load
ScrollViewReader { proxy in
    proxy.scrollTo(scrollIndex, anchor: .top)
}
```

### File Structure

```
SmartSessionRecovery/
├── SmartRecoveryApp.swift      # App entry point
├── SessionManager.swift         # Core state management & persistence
├── Screens.swift               # UI screens (Home, Form, List)
├── ViewHelpers.swift           # Custom modifiers & utilities
└── README.md                   # This file
```

| File | Purpose |
|------|---------|
| `SessionManager.swift` | Handles JSON saving/loading and the `SessionState` data model |
| `Screens.swift` | Contains the UI (Home, Form, List) and binds controls to `SessionManager` |
| `ViewHelpers.swift` | Custom modifiers for tracking visibility of list items |
| `SmartRecoveryApp.swift` | The app entry point with `@main` attribute |

---

## ⚙️ Requirements

| Component | Minimum Version |
|-----------|----------------|
| **iOS** | 16.0+ |
| **Xcode** | 14.0+ |
| **Swift** | 5.7+ |
| **SwiftUI** | 2.0+ |

### Why iOS 16+?
This project uses `NavigationStack`, which was introduced in iOS 16. For iOS 15 and below, you would need to use the older `NavigationView` API with custom path management.

---

## 📖 Usage Examples

### Basic Integration

```swift
import SwiftUI

@main
struct YourApp: App {
    @StateObject private var session = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
```

### Adding a New Screen

1. **Define the route:**
   ```swift
   enum AppRoute: Codable, Hashable {
       case home
       case form
       case list
       case newScreen  // Add this
   }
   ```

2. **Add navigation destination:**
   ```swift
   .navigationDestination(for: AppRoute.self) { route in
       switch route {
       case .newScreen:
           YourNewView()
       // ... other cases
       }
   }
   ```

3. **Navigate to it:**
   ```swift
   Button("Go to New Screen") {
       session.state.navigationPath.append(.newScreen)
   }
   ```
 
