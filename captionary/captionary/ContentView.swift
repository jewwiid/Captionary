//
//  ContentView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Main content view that handles app navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionVM: SessionVM
    
    var body: some View {
        Group {
            if sessionVM.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            Task {
                await sessionVM.loadUserData()
            }
        }
    }
}

/// Main tab view for authenticated users
struct MainTabView: View {
    @EnvironmentObject var sessionVM: SessionVM
    
    var body: some View {
        TabView {
            WizardView()
                .environmentObject(sessionVM)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Create")
                }
            
            HistoryView()
                .environmentObject(sessionVM)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            SettingsView()
                .environmentObject(sessionVM)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

/// Placeholder view for caption history
struct HistoryView: View {
    @EnvironmentObject var sessionVM: SessionVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "clock")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Caption History")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your generated captions will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("History")
        }
    }
}

/// Placeholder view for settings
struct SettingsView: View {
    @EnvironmentObject var sessionVM: SessionVM
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(sessionVM.userEmail)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Plan")
                        Spacer()
                        Text(sessionVM.planDisplayName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Usage") {
                    HStack {
                        Text("Remaining Generations")
                        Spacer()
                        Text("\(sessionVM.getRemainingGenerations())")
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Usage")
                            .font(.headline)
                        
                        ProgressView(value: sessionVM.getUsagePercentage())
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        Task {
                            await sessionVM.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionVM())
}
