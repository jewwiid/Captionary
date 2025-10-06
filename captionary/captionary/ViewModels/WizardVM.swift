//
//  WizardVM.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  ViewModel for the 4-step caption generation wizard
//

import Foundation
import SwiftUI
import PhotosUI

/// ViewModel managing the 4-step caption generation wizard
@MainActor
class WizardVM: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStep: WizardStep = .mood
    @Published var selectedMood: String = ""
    @Published var selectedTone: String = ""
    @Published var selectedGoal: String = ""
    @Published var selectedPlatform: String = "instagram"
    @Published var selectedImage: PhotosPickerItem?
    @Published var mediaDescription: String = ""
    @Published var isGenerating = false
    @Published var generatedVariants: [CaptionVariant] = []
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let captionEngine = CaptionEngine.shared
    private let supabaseClient = SupabaseClient.shared
    
    // MARK: - Wizard Steps
    enum WizardStep: Int, CaseIterable {
        case mood = 0
        case tone = 1
        case media = 2
        case goal = 3
        
        var title: String {
            switch self {
            case .mood: return "What's the vibe?"
            case .tone: return "How should it sound?"
            case .media: return "Upload a photo"
            case .goal: return "What's the purpose?"
            }
        }
        
        var progress: Double {
            return Double(self.rawValue) / Double(WizardStep.allCases.count - 1)
        }
    }
    
    // MARK: - Available Options
    let moodOptions = ["Chill", "Grateful", "Confident", "Powerful", "Inspired"]
    let toneOptions = ["Playful", "Poetic", "Bold", "Minimal", "Witty", "Authentic"]
    let goalOptions = ["Inspire", "Promote", "Entertain", "Educate", "Connect"]
    let platformOptions = ["Instagram", "TikTok", "Twitter", "LinkedIn", "Facebook"]
    
    // MARK: - Step Navigation
    func nextStep() {
        guard currentStep.rawValue < WizardStep.allCases.count - 1 else {
            // Generate captions on final step
            Task {
                await generateCaptions()
            }
            return
        }
        
        currentStep = WizardStep(rawValue: currentStep.rawValue + 1) ?? .mood
    }
    
    func previousStep() {
        guard currentStep.rawValue > 0 else { return }
        currentStep = WizardStep(rawValue: currentStep.rawValue - 1) ?? .mood
    }
    
    func goToStep(_ step: WizardStep) {
        currentStep = step
    }
    
    // MARK: - Selection Methods
    func selectMood(_ mood: String) {
        selectedMood = mood
        nextStep()
    }
    
    func selectTone(_ tone: String) {
        selectedTone = tone
        nextStep()
    }
    
    func selectGoal(_ goal: String) {
        selectedGoal = goal
        nextStep()
    }
    
    func updatePlatform(_ platform: String) {
        selectedPlatform = platform.lowercased()
    }
    
    // MARK: - Media Handling
    func updateMediaDescription(_ description: String) {
        mediaDescription = description
    }
    
    func processSelectedImage() async {
        guard let selectedImage = selectedImage else { return }
        
        do {
            if let data = try await selectedImage.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                // TODO: Implement Vision API analysis for automatic description
                // For now, use placeholder
                mediaDescription = "Selected photo with \(selectedMood.lowercased()) vibes"
            }
        } catch {
            errorMessage = "Failed to process selected image: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Caption Generation
    func generateCaptions() async {
        guard canGenerateCaptions else {
            errorMessage = "Please complete all required steps"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            // Create caption request
            let request = CaptionRequest(
                mood: selectedMood,
                mediaDescription: mediaDescription,
                goal: selectedGoal,
                tone: selectedTone,
                platform: selectedPlatform,
                mediaType: selectedImage != nil ? .photo : .video
            )
            
            // Generate captions
            let response = try await captionEngine.generateCaptions(for: request)
            generatedVariants = response.variants
            
            // Save to Supabase
            try await saveCaptionToHistory(request: request, variants: response.variants)
            
            // Increment usage counter
            try await supabaseClient.incrementUsage()
            
        } catch {
            errorMessage = "Failed to generate captions: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Validation
    var canGenerateCaptions: Bool {
        return !selectedMood.isEmpty &&
               !selectedTone.isEmpty &&
               !selectedGoal.isEmpty &&
               !mediaDescription.isEmpty
    }
    
    var isStepComplete: Bool {
        switch currentStep {
        case .mood:
            return !selectedMood.isEmpty
        case .tone:
            return !selectedTone.isEmpty
        case .media:
            return selectedImage != nil && !mediaDescription.isEmpty
        case .goal:
            return !selectedGoal.isEmpty
        }
    }
    
    // MARK: - Reset Methods
    func resetWizard() {
        currentStep = .mood
        selectedMood = ""
        selectedTone = ""
        selectedGoal = ""
        selectedPlatform = "instagram"
        selectedImage = nil
        mediaDescription = ""
        generatedVariants = []
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func saveCaptionToHistory(request: CaptionRequest, variants: [CaptionVariant]) async throws {
        // Save the first (best) variant
        if let bestVariant = variants.first {
            try await supabaseClient.saveCaption(request: request, variant: bestVariant)
        }
    }
}

// MARK: - Convenience Extensions
extension WizardVM {
    var currentStepTitle: String {
        return currentStep.title
    }
    
    var progressPercentage: Double {
        return currentStep.progress
    }
    
    var canGoNext: Bool {
        return isStepComplete
    }
    
    var canGoPrevious: Bool {
        return currentStep.rawValue > 0
    }
}
