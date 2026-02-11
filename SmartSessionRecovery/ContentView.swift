//
//  ContentView.swift
//  SmartSessionRecovery
//
//  Created by Noman belim on 10/02/26.
//
 
import Combine
import SwiftUI

// MARK: - Root View
struct ContentView: View {
    @StateObject private var session = SessionManager()
    
    var body: some View {
        NavigationStack(path: $session.state.navigationPath) {
            VStack(spacing: 20) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding()
                
                Text("Smart Recovery System")
                    .font(.title)
                    .bold()
                
                Text("Navigate, Type, or Scroll.\nThen kill the app (Stop in Xcode) and relaunch.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
                
                // Navigation Links
                NavigationLink(value: AppRoute.formScreen) {
                    Label("Go to Input Form", systemImage: "text.cursor")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                
                NavigationLink(value: AppRoute.listScreen) {
                    Label("Go to Scroll List", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button("Reset Session", role: .destructive) {
                    session.clearSession()
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Home")
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .formScreen:
                    SmartFormView(formData: $session.state.formData)
                case .listScreen:
                    SmartListView(scrollIndex: $session.state.lastScrollIndex)
                }
            }
        }
    }
}

// MARK: - Feature 1: Restore Form Inputs
struct SmartFormView: View {
    @Binding var formData: UserFormData
    
    var body: some View {
        Form {
            Section(header: Text("User Details (Auto-Saves)")) {
                TextField("Full Name", text: $formData.name)
                TextField("Email Address", text: $formData.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
            
            Section(header: Text("Preferences")) {
                Toggle("Subscribe to Newsletter", isOn: $formData.isSubscribed)
            }
            
            Section(header: Text("Bio")) {
                TextEditor(text: $formData.bio)
                    .frame(height: 100)
            }
        }
        .navigationTitle("Form Restoration")
    }
}

// MARK: - Feature 2: Restore Scroll Position
struct SmartListView: View {
    @Binding var scrollIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0..<100) { i in
                    HStack {
                        Text("Item #\(i)")
                        Spacer()
                        if i == scrollIndex {
                            Image(systemName: "eye.fill")
                                .foregroundStyle(.blue)
                                .accessibilityLabel("Last viewed")
                        }
                    }
                    .id(i)
                    .trackVisibility(index: i, tracker: $scrollIndex)
                }
            }
            .navigationTitle("Scroll Restoration")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo(scrollIndex, anchor: .top)
                    }
                }
            }
        }
    }
}
