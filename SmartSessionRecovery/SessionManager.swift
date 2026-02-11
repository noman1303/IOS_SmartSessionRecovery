//
//  SessionManager.swift
//  SmartSessionRecovery
//
//  Created by Noman belim on 11/02/26.
//

import Foundation
import SwiftUI
import Combine



enum AppRoute: String, Codable, Hashable {
    case formScreen
    case listScreen
}

struct UserFormData: Codable, Equatable {
    var name: String = ""
    var email: String = ""
    var isSubscribed: Bool = false
    var bio: String = ""
}

struct SessionState: Codable, Equatable {
    var navigationPath: [AppRoute] = []
    var formData: UserFormData = UserFormData()
    var lastScrollIndex: Int = 0 // Tracks the visible item index
}
 
@MainActor
class SessionManager: ObservableObject {
  
    @Published var state: SessionState = SessionState()
    
   
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("SavedSession.json")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSession()
        setupAutoSave()
    }
    
    
    private func setupAutoSave() {
        $state
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] newState in
                self?.saveSession(newState)
            }
            .store(in: &cancellables)
    }
    
    private func saveSession(_ currentState: SessionState) {
        do {
            let data = try JSONEncoder().encode(currentState)
            try data.write(to: savePath)
            print("💾 Session Auto-Saved")
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    func loadSession() {
        do {
            let data = try Data(contentsOf: savePath)
            let loadedState = try JSONDecoder().decode(SessionState.self, from: data)
            self.state = loadedState
            print("🚀 Session Restored: \(loadedState.navigationPath)")
        } catch {
            print("No previous session found, starting fresh.")
        }
    }
    
    // Helper to clear session (optional, e.g., on logout)
    func clearSession() {
        state = SessionState()
        try? FileManager.default.removeItem(at: savePath)
    }
}
