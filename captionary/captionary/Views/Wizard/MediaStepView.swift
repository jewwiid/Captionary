//
//  MediaStepView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Third step of wizard: media upload and description
//

import SwiftUI
import PhotosUI

/// Third step of the wizard: uploading media and providing description
struct MediaStepView: View {
    @EnvironmentObject var wizardVM: WizardVM
    @State private var showingImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Upload a photo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Add your photo and describe what's in it")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Media Upload Section
                VStack(spacing: 16) {
                    // Image Picker
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let selectedImage = wizardVM.selectedImage {
                            AsyncImage(url: selectedImage) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                
                                Text("Tap to add photo")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [10]))
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Description Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Describe your photo")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("What's in this photo? Be specific...", text: $wizardVM.mediaDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                        
                        Text("Tip: The more details you provide, the better your caption will be!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Platform Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Platform")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(wizardVM.platformOptions, id: \.self) { platform in
                                PlatformChip(
                                    platform: platform,
                                    isSelected: wizardVM.selectedPlatform == platform.lowercased(),
                                    onTap: {
                                        wizardVM.updatePlatform(platform)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $wizardVM.selectedImage)
        .onChange(of: wizardVM.selectedImage) { _, newImage in
            if newImage != nil {
                Task {
                    await wizardVM.processSelectedImage()
                }
            }
        }
    }
}

/// Platform selection chip
struct PlatformChip: View {
    let platform: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var platformIcon: String {
        switch platform.lowercased() {
        case "instagram":
            return "📷"
        case "tiktok":
            return "🎵"
        case "twitter":
            return "🐦"
        case "linkedin":
            return "💼"
        case "facebook":
            return "👥"
        default:
            return "📱"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(platformIcon)
                    .font(.title3)
                
                Text(platform)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MediaStepView()
        .environmentObject(WizardVM())
}
