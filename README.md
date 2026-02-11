Smart Session Recovery System (iOS / SwiftUI)
A robust iOS application architecture designed to automatically persist and restore user state—including navigation history, form data, and scroll positions—in the event of an app crash or forced termination.

📱 Features
Crash-Proof Navigation: Restores the exact screen the user was on (using SwiftUI NavigationStack).

Form Persistence: Saves text inputs and toggles as the user types (using Combine debouncing).

Scroll Restoration: Remembers exactly where the user was scrolling in a list and snaps back to that position on relaunch.

Codable State Management: Uses a single source of truth (JSON) stored in the documents directory.

🚀 How to Run & Test
1. Installation

Open Xcode.

Create a new SwiftUI project.

Copy the source files (SessionManager.swift, ViewHelpers.swift, Screens.swift) into your project.

Update your @main App file to use ContentView.

2. Testing the "Kill" Scenario

Since iOS apps rarely "exit" normally, you must simulate a crash or process kill to test the recovery system:

Run the App in the Simulator or on a real device via Xcode.

Interact:

Navigate to the Form Screen, type something in the "Bio" field.

OR Navigate to the Scroll List, scroll down to Item #45.

The "Kill" Switch:

Do NOT press the Home button (this only suspends the app).

DO press the Stop (Square) button in Xcode. This instantly kills the app process (simulating a crash).

Relaunch:

Press the Play button in Xcode again.

Observe:

The app will skip the Home screen and immediately push you to the Form or List screen you were just on.

Your typed text or scroll position will be restored.

🛠 Under the Hood: Code Explanation
1. The Brain: SessionManager.swift

This class is the single source of truth. It handles the "Auto-Save" logic.

Debouncing: We don't save to disk every single time a character changes (which would be slow). We use Combine's .debounce operator.

Swift
$state
    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
    .sink { ... }
Why? This waits until the user stops typing or scrolling for 0.5 seconds before writing to the file system. It balances performance with data safety.

2. The Navigation: NavigationStack

We use the modern iOS 16 data-driven navigation.

The Path:

Swift
NavigationStack(path: $session.state.navigationPath)
Instead of using standard NavigationLink(destination:...), we bind the stack to an array of Enums ([AppRoute]). When the app loads, we simply repopulate this array from the JSON file, and SwiftUI automatically rebuilds the view hierarchy.

3. Scroll Restoration: ScrollViewReader & VisibilityTracker

SwiftUI does not give us the "content offset" (y-position) easily, so we use a clever workaround.

Tracking: We attach a .onAppear modifier to every row in the list. As rows appear on the screen, we update the lastScrollIndex variable.

Swift
// ViewHelpers.swift
.onAppear { tracker = index }
Restoring: When the view loads, we use ScrollViewReader to programmatically jump to that index.

Swift
// SmartListView
proxy.scrollTo(scrollIndex, anchor: .top)
📂 Project Structure
File    Purpose
SessionManager.swift    Handles JSON saving/loading and the SessionState data model.
Screens.swift    Contains the UI (Home, Form, List) and binds UI controls to the SessionManager.
ViewHelpers.swift    Custom modifiers for tracking visibility of list items.
SmartRecoveryApp.swift    The app entry point.
⚠️ Requirements
iOS: 16.0+ (Required for NavigationStack)

Xcode: 14.0+

Swift: 5.7+
