//
//  OnboardingView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Welcome and onboarding flow for new users
//

import SwiftUI

/// Main onboarding view with welcome screen and authentication
struct OnboardingView: View {
    @StateObject private var sessionVM = SessionVM()
    @State private var showingWizard = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // App Icon and Title
                VStack(spacing: 16) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to Captionary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Create captions for your photos and videos in just 4 taps")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Features List
                VStack(spacing: 16) {
                    FeatureRow(
                        icon: "sparkles",
                        title: "AI-Powered",
                        description: "Generate engaging captions with AI"
                    )
                    
                    FeatureRow(
                        icon: "timer",
                        title: "4 Taps Only",
                        description: "Quick and simple workflow"
                    )
                    
                    FeatureRow(
                        icon: "tag",
                        title: "Smart Hashtags",
                        description: "Get relevant hashtags automatically"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await sessionVM.signInWithApple()
                            showingWizard = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Get Started")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(sessionVM.isLoading)
                    
                    if sessionVM.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    if let errorMessage = sessionVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $showingWizard) {
                WizardView()
                    .environmentObject(sessionVM)
            }
        }
    }
}

/// Feature row component for onboarding
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
