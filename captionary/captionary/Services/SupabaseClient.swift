//
//  SupabaseClient.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Supabase client for authentication and database operations
//

import Foundation
import Supabase

/// Main Supabase client for Captionary app
class SupabaseClient: ObservableObject {
    static let shared = SupabaseClient()
    
    private let supabase: SupabaseClient
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        // Initialize Supabase client with project URL and anon key from Secrets.plist
        let secrets = SecretsManager.shared
        
        guard let supabaseURL = secrets.supabaseURL,
              let supabaseKey = secrets.supabaseAnonKey else {
            fatalError("Missing Supabase configuration in Secrets.plist")
        }
        
        self.supabase = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
        
        // Check for existing session
        Task {
            await checkCurrentSession()
        }
    }
    
    // MARK: - Authentication
    
    /// Sign in with Apple
    func signInWithApple() async throws {
        let session = try await supabase.auth.signInWithApple()
        await MainActor.run {
            self.currentUser = session.user
            self.isAuthenticated = true
        }
    }
    
    /// Sign out user
    func signOut() async throws {
        try await supabase.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    /// Check current authentication session
    private func checkCurrentSession() async {
        do {
            let session = try await supabase.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Profile Management
    
    /// Get user profile
    func getProfile() async throws -> Profile {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("uid", value: user.id)
            .single()
            .execute()
            .value
        
        return profile
    }
    
    /// Update user profile
    func updateProfile(_ profile: Profile) async throws {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        try await supabase
            .from("profiles")
            .update(profile)
            .eq("uid", value: user.id)
            .execute()
    }
    
    // MARK: - Subscription Management
    
    /// Get user subscription
    func getSubscription() async throws -> Subscription {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let subscription: Subscription = try await supabase
            .from("subscriptions")
            .select()
            .eq("uid", value: user.id)
            .single()
            .execute()
            .value
        
        return subscription
    }
    
    // MARK: - Usage Tracking
    
    /// Get current month usage
    func getCurrentUsage() async throws -> UsageCounter {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let currentMonth = DateFormatter().string(from: Date()).prefix(7) // YYYY-MM format
        
        do {
            let usage: UsageCounter = try await supabase
                .from("usage_counters")
                .select()
                .eq("uid", value: user.id)
                .eq("yyyymm", value: String(currentMonth))
                .single()
                .execute()
                .value
            
            return usage
        } catch {
            // Return zero usage if no record exists
            return UsageCounter(uid: user.id, yyyymm: String(currentMonth), generations: 0)
        }
    }
    
    /// Increment usage counter
    func incrementUsage() async throws {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let currentMonth = DateFormatter().string(from: Date()).prefix(7)
        
        try await supabase
            .from("usage_counters")
            .upsert([
                "uid": user.id,
                "yyyymm": String(currentMonth),
                "generations": 1
            ])
            .execute()
    }
    
    // MARK: - Caption Storage
    
    /// Save generated caption
    func saveCaption(request: CaptionRequest, variant: CaptionVariant) async throws {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let caption = Caption(
            uid: user.id,
            request: try JSONEncoder().encode(request),
            variant: try JSONEncoder().encode(variant)
        )
        
        try await supabase
            .from("captions")
            .insert(caption)
            .execute()
    }
    
    /// Get user's caption history
    func getCaptionHistory(limit: Int = 10) async throws -> [Caption] {
        guard let user = currentUser else {
            throw SupabaseError.notAuthenticated
        }
        
        let captions: [Caption] = try await supabase
            .from("captions")
            .select()
            .eq("uid", value: user.id)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        
        return captions
    }
}

// MARK: - Data Models

struct Profile: Codable {
    let uid: UUID
    let email: String
    let displayName: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uid, email, displayName = "display_name", createdAt = "created_at"
    }
}

struct Subscription: Codable {
    let uid: UUID
    let plan: Plan
    let renewsAt: Date?
    let status: String
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uid, plan, renewsAt = "renews_at", status, updatedAt = "updated_at"
    }
}

enum Plan: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium"
    case pro = "pro"
}

struct UsageCounter: Codable {
    let uid: UUID
    let yyyymm: String
    let generations: Int
}

struct Caption: Codable {
    let id: UUID
    let uid: UUID
    let request: Data
    let variant: Data
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, uid, request, variant, createdAt = "created_at"
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notAuthenticated
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .networkError:
            return "Network connection error"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
