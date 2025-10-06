//
//  ResultsView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Results view showing generated caption variants
//

import SwiftUI

/// Results view displaying generated caption variants with options to copy, share, and save
struct ResultsView: View {
    let variants: [CaptionVariant]
    @EnvironmentObject var wizardVM: WizardVM
    @State private var selectedVariant: CaptionVariant?
    @State private var showingShareSheet = false
    @State private var showingCopiedAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Your Captions Are Ready!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Choose your favorite and share it with the world")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Caption Variants
                    LazyVStack(spacing: 16) {
                        ForEach(variants) { variant in
                            CaptionVariantCard(
                                variant: variant,
                                isSelected: selectedVariant?.id == variant.id,
                                onSelect: {
                                    selectedVariant = variant
                                },
                                onCopy: {
                                    copyToClipboard(variant)
                                },
                                onShare: {
                                    shareVariant(variant)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    if let selected = selectedVariant {
                        VStack(spacing: 16) {
                            Button(action: {
                                copyToClipboard(selected)
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Caption")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                shareVariant(selected)
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Generate More Button
                    Button(action: {
                        wizardVM.resetWizard()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Generate More")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        wizardVM.resetWizard()
                    }
                }
            }
            .alert("Copied!", isPresented: $showingCopiedAlert) {
                Button("OK") { }
            } message: {
                Text("Caption copied to clipboard")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let selected = selectedVariant {
                    ShareSheet(activityItems: [selected.caption])
                }
            }
        }
        .onAppear {
            // Auto-select the first (best) variant
            selectedVariant = variants.first
        }
    }
    
    // MARK: - Actions
    private func copyToClipboard(_ variant: CaptionVariant) {
        UIPasteboard.general.string = variant.caption
        showingCopiedAlert = true
    }
    
    private func shareVariant(_ variant: CaptionVariant) {
        showingShareSheet = true
    }
}

/// Individual caption variant card
struct CaptionVariantCard: View {
    let variant: CaptionVariant
    let isSelected: Bool
    let onSelect: () -> Void
    let onCopy: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Quality Score Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quality Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(variant.qualityPercentage)%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(variant.qualityRating.color))
                        
                        Text(variant.qualityRating.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Tone Badge
                Text(variant.tone)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
                    .foregroundColor(.blue)
            }
            
            // Caption Text
            Button(action: onSelect) {
                Text(variant.caption)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Hashtags
            if !variant.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(variant.hashtags, id: \.self) { hashtag in
                            Text("#\(hashtag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Alt Text
            VStack(alignment: .leading, spacing: 4) {
                Text("Alt Text")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(variant.altText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onCopy) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Button(action: onShare) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

/// Share sheet for sharing captions
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultsView(variants: [
        CaptionVariant(
            caption: "✨ Ready to make an impact! #motivation #success",
            hashtags: ["motivation", "success", "inspire"],
            altText: "A photo representing confident energy",
            qualityScore: 0.85,
            tone: "confident"
        ),
        CaptionVariant(
            caption: "🚀 Every step forward counts. Keep pushing! #progress #mindset",
            hashtags: ["progress", "mindset", "growth"],
            altText: "Visual representation of inspiration",
            qualityScore: 0.78,
            tone: "confident"
        )
    ])
    .environmentObject(WizardVM())
}
