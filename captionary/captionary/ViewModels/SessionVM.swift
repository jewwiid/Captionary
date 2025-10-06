//
//  SessionVM.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  ViewModel for user session, authentication, and subscription management
//

import Foundation
import SwiftUI

/// ViewModel managing user session, authentication, and subscription status
@MainActor
class SessionVM: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userProfile: Profile?
    @Published var subscription: Subscription?
    @Published var currentUsage: UsageCounter?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let supabaseClient = SupabaseClient.shared
    
    // MARK: - Usage Limits
    private let usageLimits: [Plan: Int] = [
        .free: 10,
        .premium: 100,
        .pro: 1000
    ]
    
    init() {
        setupAuthListener()
        Task {
            await loadUserData()
        }
    }
    
    // MARK: - Authentication
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseClient.signInWithApple()
            await loadUserData()
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await supabaseClient.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.userProfile = nil
                self.subscription = nil
                self.currentUsage = nil
                self.isAuthenticated = false
            }
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - User Data Management
    func loadUserData() async {
        guard supabaseClient.isAuthenticated else { return }
        
        isLoading = true
        
        do {
            async let profileTask = supabaseClient.getProfile()
            async let subscriptionTask = supabaseClient.getSubscription()
            async let usageTask = supabaseClient.getCurrentUsage()
            
            let (profile, subscription, usage) = try await (profileTask, subscriptionTask, usageTask)
            
            await MainActor.run {
                self.userProfile = profile
                self.subscription = subscription
                self.currentUsage = usage
                self.isAuthenticated = true
            }
            
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshUserData() async {
        await loadUserData()
    }
    
    // MARK: - Usage Management
    func canGenerateCaption() -> Bool {
        guard let usage = currentUsage,
              let subscription = subscription else {
            return false
        }
        
        let limit = usageLimits[subscription.plan] ?? 0
        return usage.generations < limit
    }
    
    func getRemainingGenerations() -> Int {
        guard let usage = currentUsage,
              let subscription = subscription else {
            return 0
        }
        
        let limit = usageLimits[subscription.plan] ?? 0
        return max(0, limit - usage.generations)
    }
    
    func getUsagePercentage() -> Double {
        guard let usage = currentUsage,
              let subscription = subscription else {
            return 0.0
        }
        
        let limit = usageLimits[subscription.plan] ?? 1
        return Double(usage.generations) / Double(limit)
    }
    
    // MARK: - Subscription Management
    func updateSubscriptionStatus() async {
        do {
            let updatedSubscription = try await supabaseClient.getSubscription()
            await MainActor.run {
                self.subscription = updatedSubscription
            }
        } catch {
            errorMessage = "Failed to update subscription: \(error.localizedDescription)"
        }
    }
    
    var isSubscriptionActive: Bool {
        guard let subscription = subscription else { return false }
        return subscription.status == "active"
    }
    
    var currentPlan: Plan {
        return subscription?.plan ?? .free
    }
    
    var shouldShowPaywall: Bool {
        return !canGenerateCaption() && isAuthenticated
    }
    
    // MARK: - Private Methods
    private func setupAuthListener() {
        // Listen for authentication state changes
        supabaseClient.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        supabaseClient.$currentUser
            .assign(to: &$currentUser)
    }
}

// MARK: - Convenience Extensions
extension SessionVM {
    var userDisplayName: String {
        return userProfile?.displayName ?? currentUser?.email ?? "User"
    }
    
    var userEmail: String {
        return userProfile?.email ?? currentUser?.email ?? ""
    }
    
    var planDisplayName: String {
        switch currentPlan {
        case .free:
            return "Free"
        case .premium:
            return "Premium"
        case .pro:
            return "Pro"
        }
    }
    
    var planFeatures: [String] {
        switch currentPlan {
        case .free:
            return ["10 generations/month", "Basic captions", "Standard hashtags"]
        case .premium:
            return ["100 generations/month", "Advanced captions", "Premium hashtags", "Alt text generation"]
        case .pro:
            return ["1000 generations/month", "Premium captions", "Custom hashtags", "Advanced alt text", "Priority support"]
        }
    }
}
