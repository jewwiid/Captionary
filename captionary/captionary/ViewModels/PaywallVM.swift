//
//  PaywallVM.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  ViewModel for subscription management and StoreKit 2 integration
//

import Foundation
import StoreKit

/// ViewModel for managing subscription purchases and StoreKit 2 integration
@MainActor
class PaywallVM: ObservableObject {
    // MARK: - Published Properties
    @Published var availablePlans: [SubscriptionPlan] = []
    @Published var selectedPlan: SubscriptionPlan?
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let purchaseManager = PurchaseManager.shared
    
    init() {
        loadSubscriptionPlans()
    }
    
    // MARK: - Plan Management
    func loadSubscriptionPlans() {
        // Mock subscription plans - in production, these would come from StoreKit
        availablePlans = [
            SubscriptionPlan(
                id: "premium_monthly",
                name: "Premium",
                description: "Perfect for content creators",
                price: "$9.99/month",
                isPopular: true,
                features: [
                    "100 generations/month",
                    "Premium captions",
                    "Smart hashtags",
                    "Alt text generation"
                ]
            ),
            SubscriptionPlan(
                id: "pro_monthly",
                name: "Pro",
                description: "For power users and businesses",
                price: "$19.99/month",
                isPopular: false,
                features: [
                    "1000 generations/month",
                    "Premium captions",
                    "Custom hashtags",
                    "Advanced alt text",
                    "Priority support"
                ]
            ),
            SubscriptionPlan(
                id: "premium_yearly",
                name: "Premium Yearly",
                description: "Best value - save 20%",
                price: "$99.99/year",
                isPopular: false,
                features: [
                    "100 generations/month",
                    "Premium captions",
                    "Smart hashtags",
                    "Alt text generation",
                    "20% savings"
                ]
            )
        ]
        
        // Auto-select popular plan
        selectedPlan = availablePlans.first { $0.isPopular }
    }
    
    func selectPlan(_ plan: SubscriptionPlan) {
        selectedPlan = plan
    }
    
    // MARK: - Purchase Management
    func purchasePlan(_ plan: SubscriptionPlan) async throws {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual StoreKit 2 purchase flow
            // This is a placeholder implementation
            try await simulatePurchase(plan)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isPurchasing = false
    }
    
    private func simulatePurchase(_ plan: SubscriptionPlan) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate purchase success (in real app, this would be StoreKit response)
        // For now, we'll just update the local state
    }
    
    private func updateSubscriptionStatus() async {
        // TODO: Refresh subscription status from Supabase
        // This would typically involve calling the backend to verify the purchase
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        // TODO: Implement StoreKit 2 restore functionality
        // This would restore previous purchases and update subscription status
    }
}

// MARK: - Data Models

struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: String
    let isPopular: Bool
    let features: [String]
}

// MARK: - StoreKit 2 Integration

/// Purchase manager for StoreKit 2 integration
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var availableProducts: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        do {
            let productIDs = [
                "captionary.premium.monthly",
                "captionary.pro.monthly",
                "captionary.premium.yearly"
            ]
            
            let products = try await Product.products(for: productIDs)
            await MainActor.run {
                self.availableProducts = products
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            
            await MainActor.run {
                self.purchasedProductIDs.insert(product.id)
            }
            
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        default:
            return nil
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        
        for await result in Transaction.currentEntitlements {
            let transaction = try checkVerified(result)
            await MainActor.run {
                self.purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case unverifiedTransaction
    case purchaseFailed
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            return "Transaction could not be verified"
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .productNotFound:
            return "Product not found"
        }
    }
}
