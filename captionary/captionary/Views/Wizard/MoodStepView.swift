//
//  MoodStepView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  First step of wizard: mood/vibe selection
//

import SwiftUI

/// First step of the wizard: selecting the mood/vibe for the caption
struct MoodStepView: View {
    @EnvironmentObject var wizardVM: WizardVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("What's the vibe?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose the mood that best fits your content")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Mood Options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(wizardVM.moodOptions, id: \.self) { mood in
                        MoodChip(
                            mood: mood,
                            isSelected: wizardVM.selectedMood == mood,
                            onTap: {
                                wizardVM.selectMood(mood)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

/// Individual mood selection chip
struct MoodChip: View {
    let mood: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var moodEmoji: String {
        switch mood.lowercased() {
        case "chill":
            return "😌"
        case "grateful":
            return "🙏"
        case "confident":
            return "💪"
        case "powerful":
            return "⚡"
        case "inspired":
            return "✨"
        default:
            return "🌟"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(moodEmoji)
                    .font(.system(size: 40))
                
                Text(mood)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoodStepView()
        .environmentObject(WizardVM())
}
