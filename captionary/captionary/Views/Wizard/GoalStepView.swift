//
//  GoalStepView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Fourth step of wizard: goal/purpose selection
//

import SwiftUI

/// Fourth step of the wizard: selecting the goal/purpose for the caption
struct GoalStepView: View {
    @EnvironmentObject var wizardVM: WizardVM
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("What's the purpose?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("What do you want to achieve with this post?")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Goal Options
                VStack(spacing: 16) {
                    ForEach(wizardVM.goalOptions, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: wizardVM.selectedGoal == goal,
                            onTap: {
                                wizardVM.selectGoal(goal)
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

/// Individual goal selection card
struct GoalCard: View {
    let goal: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var goalIcon: String {
        switch goal.lowercased() {
        case "inspire":
            return "✨"
        case "promote":
            return "📢"
        case "entertain":
            return "🎭"
        case "educate":
            return "📚"
        case "connect":
            return "🤝"
        default:
            return "🎯"
        }
    }
    
    private var goalDescription: String {
        switch goal.lowercased() {
        case "inspire":
            return "Motivate and uplift your audience"
        case "promote":
            return "Showcase products or services"
        case "entertain":
            return "Create fun and engaging content"
        case "educate":
            return "Share knowledge and insights"
        case "connect":
            return "Build relationships and community"
        default:
            return "Share your message"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Text(goalIcon)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .blue : .primary)
                    
                    Text(goalDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
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
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GoalStepView()
        .environmentObject(WizardVM())
}
