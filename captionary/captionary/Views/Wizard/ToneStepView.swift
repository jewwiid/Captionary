//
//  ToneStepView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Second step of wizard: tone/style selection
//

import SwiftUI

/// Second step of the wizard: selecting the tone/style for the caption
struct ToneStepView: View {
    @EnvironmentObject var wizardVM: WizardVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("How should it sound?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose the tone that matches your brand voice")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Tone Options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(wizardVM.toneOptions, id: \.self) { tone in
                        ToneChip(
                            tone: tone,
                            isSelected: wizardVM.selectedTone == tone,
                            onTap: {
                                wizardVM.selectTone(tone)
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

/// Individual tone selection chip
struct ToneChip: View {
    let tone: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var toneDescription: String {
        switch tone.lowercased() {
        case "playful":
            return "Fun and lighthearted"
        case "poetic":
            return "Artistic and flowing"
        case "bold":
            return "Strong and confident"
        case "minimal":
            return "Simple and clean"
        case "witty":
            return "Clever and humorous"
        case "authentic":
            return "Genuine and real"
        default:
            return "Balanced and engaging"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(tone)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(toneDescription)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
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
    ToneStepView()
        .environmentObject(WizardVM())
}
