//
//  WizardView.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Main wizard view managing the 4-step caption generation flow
//

import SwiftUI

/// Main wizard view that orchestrates the 4-step caption generation process
struct WizardView: View {
    @StateObject private var wizardVM = WizardVM()
    @EnvironmentObject var sessionVM: SessionVM
    @State private var showingResults = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Header
                ProgressHeader(
                    currentStep: wizardVM.currentStep,
                    progress: wizardVM.progressPercentage
                )
                
                // Step Content
                TabView(selection: $wizardVM.currentStep) {
                    MoodStepView()
                        .environmentObject(wizardVM)
                        .tag(WizardVM.WizardStep.mood)
                    
                    ToneStepView()
                        .environmentObject(wizardVM)
                        .tag(WizardVM.WizardStep.tone)
                    
                    MediaStepView()
                        .environmentObject(wizardVM)
                        .tag(WizardVM.WizardStep.media)
                    
                    GoalStepView()
                        .environmentObject(wizardVM)
                        .tag(WizardVM.WizardStep.goal)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: wizardVM.currentStep)
                
                // Navigation Controls
                NavigationControls(
                    canGoNext: wizardVM.canGoNext,
                    canGoPrevious: wizardVM.canGoPrevious,
                    isGenerating: wizardVM.isGenerating,
                    onNext: {
                        if wizardVM.currentStep == .goal {
                            // Check usage limits before generating
                            if sessionVM.canGenerateCaption() {
                                Task {
                                    await wizardVM.generateCaptions()
                                    showingResults = true
                                }
                            } else {
                                showingPaywall = true
                            }
                        } else {
                            wizardVM.nextStep()
                        }
                    },
                    onPrevious: wizardVM.previousStep
                )
            }
            .navigationTitle("Create Caption")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingResults) {
                ResultsView(variants: wizardVM.generatedVariants)
                    .environmentObject(wizardVM)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(sessionVM)
            }
            .alert("Error", isPresented: .constant(wizardVM.errorMessage != nil)) {
                Button("OK") {
                    wizardVM.errorMessage = nil
                }
            } message: {
                Text(wizardVM.errorMessage ?? "")
            }
        }
    }
}

/// Progress header showing current step and progress bar
struct ProgressHeader: View {
    let currentStep: WizardVM.WizardStep
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Step Title
            Text(currentStep.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Progress Indicators
            HStack(spacing: 12) {
                ForEach(WizardVM.WizardStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            
            // Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

/// Navigation controls for wizard steps
struct NavigationControls: View {
    let canGoNext: Bool
    let canGoPrevious: Bool
    let isGenerating: Bool
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Previous Button
            Button(action: onPrevious) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            }
            .disabled(!canGoPrevious || isGenerating)
            
            Spacer()
            
            // Next/Generate Button
            Button(action: onNext) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text(isGenerating ? "Generating..." : "Next")
                    }
                    
                    if !isGenerating {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(minWidth: 100)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canGoNext ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canGoNext || isGenerating)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    WizardView()
        .environmentObject(SessionVM())
}
