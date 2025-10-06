//
//  PaywallView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Paywall view for subscription management
//

import SwiftUI

/// Paywall view for subscription management and upgrade options
struct PaywallView: View {
    @EnvironmentObject var sessionVM: SessionVM
    @StateObject private var paywallVM = PaywallVM()
    @Environment(\.dismiss) private var dismiss
    @State private var showingPurchaseAlert = false
    @State private var purchaseErrorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Upgrade to Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock unlimited caption generation and premium features")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Current Usage
                    if let usage = sessionVM.currentUsage {
                        VStack(spacing: 8) {
                            Text("Current Usage")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ProgressView(value: sessionVM.getUsagePercentage())
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                            
                            Text("\(usage.generations) / \(sessionVM.currentPlan == .free ? 10 : 100) generations used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal)
                    }
                    
                    // Subscription Plans
                    VStack(spacing: 16) {
                        Text("Choose Your Plan")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(paywallVM.availablePlans, id: \.id) { plan in
                                PlanCard(
                                    plan: plan,
                                    isSelected: paywallVM.selectedPlan?.id == plan.id,
                                    onSelect: {
                                        paywallVM.selectPlan(plan)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Features Comparison
                    VStack(spacing: 16) {
                        Text("What's Included")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "infinity",
                                title: "Unlimited Generations",
                                description: "Generate as many captions as you need",
                                isIncluded: true
                            )
                            
                            FeatureRow(
                                icon: "sparkles",
                                title: "Premium Quality",
                                description: "Higher quality AI models for better results",
                                isIncluded: true
                            )
                            
                            FeatureRow(
                                icon: "tag",
                                title: "Smart Hashtags",
                                description: "Advanced hashtag suggestions",
                                isIncluded: true
                            )
                            
                            FeatureRow(
                                icon: "eye",
                                title: "Alt Text Generation",
                                description: "Automatic accessibility descriptions",
                                isIncluded: sessionVM.currentPlan != .free
                            )
                            
                            FeatureRow(
                                icon: "headphones",
                                title: "Priority Support",
                                description: "Get help when you need it",
                                isIncluded: sessionVM.currentPlan == .pro
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Purchase Button
                    if let selectedPlan = paywallVM.selectedPlan {
                        Button(action: {
                            purchasePlan(selectedPlan)
                        }) {
                            HStack {
                                if paywallVM.isPurchasing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Start \(selectedPlan.name)")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(paywallVM.isPurchasing)
                        .padding(.horizontal)
                    }
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("Subscriptions auto-renew. Cancel anytime in Settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                // TODO: Open terms
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            
                            Button("Privacy Policy") {
                                // TODO: Open privacy policy
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Error", isPresented: .constant(purchaseErrorMessage != nil)) {
                Button("OK") {
                    purchaseErrorMessage = nil
                }
            } message: {
                Text(purchaseErrorMessage ?? "")
            }
        }
    }
    
    // MARK: - Actions
    private func purchasePlan(_ plan: SubscriptionPlan) {
        Task {
            do {
                try await paywallVM.purchasePlan(plan)
                await sessionVM.refreshUserData()
                dismiss()
            } catch {
                purchaseErrorMessage = error.localizedDescription
            }
        }
    }
}

/// Individual subscription plan card
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .blue : .primary)
                        
                        Spacer()
                        
                        if plan.isPopular {
                            Text("POPULAR")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(plan.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color(.systemGray5), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Feature row component for paywall
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isIncluded: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isIncluded ? icon : "xmark")
                .font(.title3)
                .foregroundColor(isIncluded ? .green : .red)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isIncluded ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SessionVM())
}
